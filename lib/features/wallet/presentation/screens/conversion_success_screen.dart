import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/wallet_models.dart';
import '../widgets/wallet_widgets.dart';

class ConversionSuccessScreen extends StatelessWidget {
  final bool isStarToTCoin;
  final int sourceAmount;
  final int targetAmount;
  final int remainingSourceBalance;
  final WalletTransaction transaction;

  const ConversionSuccessScreen({
    super.key,
    required this.isStarToTCoin,
    required this.sourceAmount,
    required this.targetAmount,
    required this.remainingSourceBalance,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final receivedTitle = isStarToTCoin ? '$targetAmount T Coins' : '$targetAmount Stars';

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
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Radiant Celebration Star Graphic matching reference image 9
              const Center(
                child: CelebrationStarWidget(size: 170),
              ),

              const SizedBox(height: 24),
              Text(
                'Conversion Successful!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You have received ',
                    style: GoogleFonts.outfit(
                      color: WalletPalette.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    receivedTitle,
                    style: GoogleFonts.outfit(
                      color: WalletPalette.goldAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Details Card matching reference image 9
              WalletNeonCard(
                padding: const EdgeInsets.all(20),
                borderColor: const Color(0xFF24326A),
                child: Column(
                  children: [
                    _buildDetailRow(
                      isStarToTCoin ? 'Stars Converted' : 'T Coins Converted',
                      '$sourceAmount',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Color(0xFF1E2856), height: 1),
                    ),
                    _buildDetailRow(
                      isStarToTCoin ? 'T Coins Received' : 'Stars Received',
                      '$targetAmount',
                      isHighlight: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Color(0xFF1E2856), height: 1),
                    ),
                    _buildDetailRow(
                      isStarToTCoin ? 'Remaining Stars' : 'Remaining T Coins',
                      '$remainingSourceBalance',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Color(0xFF1E2856), height: 1),
                    ),
                    _buildDetailRow('Transaction ID', transaction.id),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              WalletActionButton(
                label: 'Back to Wallet',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 12),
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
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: isHighlight ? WalletPalette.goldAccent : Colors.white,
            fontSize: 15,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
