import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/wallet_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _currentBalance = 0.0;
  bool _isLoading = false;

  late final String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = Provider.of<AuthService>(context, listen: false).currentUser?.id;
    if (_uid != null) {
      WalletService().balanceStream(_uid).listen((bal) {
        if (mounted) setState(() => _currentBalance = bal);
      });
    }
  }

  Future<void> _addFunds() async {
    if (_uid == null) return;
    setState(() => _isLoading = true);
    try {
      // top up by a fixed amount for demo
      await WalletService().addFunds(_uid, 100.0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added \$100 to wallet')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add funds: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Balance',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                '\$${_currentBalance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: _isLoading ? 'Adding...' : 'Add \$100 (demo)',
                onPressed: _isLoading ? null : _addFunds,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
