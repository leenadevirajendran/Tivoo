import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/wallet_models.dart';
import '../widgets/wallet_widgets.dart';
import 'activity_history_screen.dart';

class WithdrawalStatusScreen extends StatelessWidget {
  final WalletTransaction transaction;
  final BankAccount bankAccount;
  final int tCoinsAmount;
  final double payoutAmount;

  const WithdrawalStatusScreen({
    super.key,
    required this.transaction,
    required this.bankAccount,
    required this.tCoinsAmount,
    required this.payoutAmount,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: WalletScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          title: Text(
            'Withdrawal Request',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Cyan Processing Badge matching reference image 10
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    border: Border.all(
                      color: const Color(0xFF00E5FF),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Color(0xFF00E5FF),
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Text(
                'Processing',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your withdrawal request is under review.\nIt usually takes 1–3 business days.',
                style: GoogleFonts.outfit(
                  color: WalletPalette.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 1),

              // Withdrawal Details Card matching reference image 10
              WalletNeonCard(
                padding: const EdgeInsets.all(20),
                borderColor: const Color(0xFF24326A),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Withdrawal Details',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildDetailRow('T Coins', '$tCoinsAmount'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFF1E2856), height: 1),
                    ),
                    _buildDetailRow(
                      'Payout Amount',
                      '₹${payoutAmount.toStringAsFixed(2)}',
                      isHighlight: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFF1E2856), height: 1),
                    ),
                    _buildDetailRow('Bank Account', bankAccount.displayName),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFF1E2856), height: 1),
                    ),
                    _buildDetailRow('Request ID', transaction.id),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFF1E2856), height: 1),
                    ),
                    _buildDetailRow('Date', transaction.dateText),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              WalletActionButton(
                label: 'View History',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ActivityHistoryScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Back to Wallet',
                  style: GoogleFonts.outfit(
                    color: WalletPalette.electricBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: WalletPalette.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: isHighlight ? WalletPalette.goldAccent : Colors.white,
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
