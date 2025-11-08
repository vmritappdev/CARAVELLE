import 'package:caravelle/uittility/conasthan_api.dart' as Utility;

import 'package:flutter/material.dart';


class ValidityScreen extends StatefulWidget {
  const ValidityScreen({super.key});

  @override
  State<ValidityScreen> createState() => _ValidityScreenState();
}

class _ValidityScreenState extends State<ValidityScreen> {
  bool isLoadingValidity = true;
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    _checkValidity();
  }

  Future<void> _checkValidity() async {
    bool result = await Utility.fetchValidityStatus();
    setState(() {
      isValid = result;
      isLoadingValidity = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Center(
        child: isLoadingValidity
            ? const CircularProgressIndicator()
            : isValid
                ? const Text('✅ Scheme Active')
                : const Text('❌ Scheme Expired'),
      
    );
  }
}
