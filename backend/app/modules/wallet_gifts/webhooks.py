from __future__ import annotations
import base64
import hashlib
import hmac
import json
import time
from typing import Any

from cryptography import x509
import httpx
import jwt

from app.core.config import get_settings
from app.core.exceptions import BadRequestError, ServiceUnavailableError, UnauthorizedError


def verify_stripe_signature(
    raw_body: bytes,
    signature_header: str,
    tolerance_seconds: int = 300,
) -> dict[str, Any]:
    """Verify Stripe-Signature HMAC-SHA256 header and parse event JSON."""
    settings = get_settings()
    secret = settings.stripe_webhook_secret.strip()
    if not secret:
        raise ServiceUnavailableError("STRIPE_WEBHOOK_SECRET is not configured in .env")
    if not signature_header:
        raise UnauthorizedError("Missing Stripe-Signature header")

    timestamp: int | None = None
    signatures_v1: list[str] = []
    for part in signature_header.split(","):
        if "=" not in part:
            continue
        k, v = part.strip().split("=", 1)
        if k == "t":
            try:
                timestamp = int(v)
            except ValueError as exc:
                raise UnauthorizedError("Invalid Stripe signature timestamp") from exc
        elif k == "v1":
            signatures_v1.append(v)

    if timestamp is None or not signatures_v1:
        raise UnauthorizedError("Malformed Stripe-Signature header")

    if abs(int(time.time()) - timestamp) > tolerance_seconds:
        raise UnauthorizedError("Stripe webhook timestamp outside tolerance window")

    signed_payload = f"{timestamp}.".encode("utf-8") + raw_body
    expected_sig = hmac.new(
        secret.encode("utf-8"), signed_payload, hashlib.sha256
    ).hexdigest()

    if not any(hmac.compare_digest(expected_sig, cand) for cand in signatures_v1):
        raise UnauthorizedError("Invalid Stripe webhook signature")

    try:
        return json.loads(raw_body.decode("utf-8"))
    except json.JSONDecodeError as exc:
        raise BadRequestError("Invalid JSON webhook payload") from exc


def create_stripe_checkout_session(
    order_id: str,
    user_id: str,
    package_id: str,
    package_title: str,
    coins_total: int,
    price_cents: int,
    currency: str,
) -> tuple[str, str]:
    """Create a real Stripe Checkout Session via Stripe HTTPS REST API."""
    settings = get_settings()
    secret_key = settings.stripe_secret_key.strip()
    if not secret_key:
        raise ServiceUnavailableError("STRIPE_SECRET_KEY is not configured in .env")

    form_data = {
        "mode": "payment",
        "success_url": settings.stripe_success_url,
        "cancel_url": settings.stripe_cancel_url,
        "client_reference_id": order_id,
        "line_items[0][price_data][currency]": currency.lower(),
        "line_items[0][price_data][product_data][name]": f"{package_title} ({coins_total} Coins)",
        "line_items[0][price_data][unit_amount]": str(price_cents),
        "line_items[0][quantity]": "1",
        "metadata[order_id]": order_id,
        "metadata[user_id]": user_id,
        "metadata[package_id]": package_id,
    }
    with httpx.Client(timeout=15.0) as client:
        res = client.post(
            "https://api.stripe.com/v1/checkout/sessions",
            auth=(secret_key, ""),
            data=form_data,
        )
        if res.status_code >= 400:
            raise BadRequestError(f"Stripe Checkout creation failed: {res.text[:240]}")
        data = res.json()
    return str(data["id"]), str(data["url"])


def verify_google_play_purchase(product_id: str, purchase_token: str) -> dict[str, Any]:
    """Verify an Android Google Play product purchase via Google Play Android Publisher API."""
    settings = get_settings()
    sa_raw = settings.google_play_service_account_json.strip()
    package_name = settings.google_play_package_name.strip()
    if not sa_raw or not package_name:
        raise ServiceUnavailableError(
            "GOOGLE_PLAY_PACKAGE_NAME and GOOGLE_PLAY_SERVICE_ACCOUNT_JSON must be configured in .env"
        )

    sa_data = json.loads(sa_raw)
    now = int(time.time())
    token_uri = str(sa_data.get("token_uri") or "https://oauth2.googleapis.com/token")
    assertion = jwt.encode(
        {
            "iss": sa_data["client_email"],
            "scope": "https://www.googleapis.com/auth/androidpublisher",
            "aud": token_uri,
            "iat": now,
            "exp": now + 3600,
        },
        sa_data["private_key"],
        algorithm="RS256",
    )

    with httpx.Client(timeout=15.0) as client:
        oauth_res = client.post(
            token_uri,
            data={
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": assertion,
            },
        )
        oauth_res.raise_for_status()
        access_token = str(oauth_res.json()["access_token"])

        verify_url = (
            f"https://androidpublisher.googleapis.com/androidpublisher/v3/applications/"
            f"{package_name}/purchases/products/{product_id}/tokens/{purchase_token}"
        )
        verify_res = client.get(
            verify_url, headers={"Authorization": f"Bearer {access_token}"}
        )
        if verify_res.status_code >= 400:
            raise BadRequestError(f"Google Play verification rejected token ({verify_res.status_code})")
        purchase_data = verify_res.json()

    if int(purchase_data.get("purchaseState", -1)) != 0:
        raise BadRequestError("Google Play purchase is not in Purchased state")
    return purchase_data


def verify_apple_receipt(receipt_data: str) -> dict[str, Any]:
    """Verify an iOS receipt against Apple App Store verifyReceipt endpoint."""
    settings = get_settings()
    shared_secret = settings.apple_shared_secret.strip()
    if not shared_secret:
        raise ServiceUnavailableError("APPLE_SHARED_SECRET is not configured in .env")

    payload = {
        "receipt-data": receipt_data,
        "password": shared_secret,
        "exclude-old-transactions": True,
    }
    with httpx.Client(timeout=15.0) as client:
        res = client.post("https://buy.itunes.apple.com/verifyReceipt", json=payload)
        data = res.json()
        if data.get("status") == 21007:
            res = client.post("https://sandbox.itunes.apple.com/verifyReceipt", json=payload)
            data = res.json()

    if int(data.get("status", -1)) != 0:
        raise BadRequestError(f"Apple receipt verification failed (status {data.get('status')})")
    return data


def decode_apple_signed_jws(signed_payload: str) -> dict[str, Any]:
    """Verify App Store Server Notification v2 ES256 JWS using embedded x5c certificate chain."""
    try:
        header = jwt.get_unverified_header(signed_payload)
        x5c = header.get("x5c") or []
        if not x5c:
            raise UnauthorizedError("Missing x5c certificate chain in Apple JWS")
        cert_der = base64.b64decode(x5c[0])
        cert = x509.load_der_x509_certificate(cert_der)
        decoded = jwt.decode(
            signed_payload,
            cert.public_key(),
            algorithms=[header.get("alg", "ES256")],
            options={"verify_aud": False},
        )
    except UnauthorizedError:
        raise
    except Exception as exc:
        raise UnauthorizedError(f"Invalid Apple signed JWS: {exc}") from exc

    settings = get_settings()
    expected_bundle = settings.apple_bundle_id.strip()
    bundle_id = decoded.get("data", {}).get("bundleId")
    if expected_bundle and bundle_id and bundle_id != expected_bundle:
        raise UnauthorizedError("Apple notification bundleId mismatch")
    return decoded
