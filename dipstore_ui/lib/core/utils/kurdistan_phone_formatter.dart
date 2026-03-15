import 'package:flutter/services.dart';

class KurdistanPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Permanent prefix: +964 
    final String prefix = '+964 ';

    // If user tries to delete the prefix or part of it, revert or reset
    if (!newValue.text.startsWith(prefix)) {
      // Revert to oldValue if it was valid, else set to pure prefix
      return oldValue.text.startsWith(prefix)
          ? oldValue
          : TextEditingValue(
              text: prefix,
              selection: TextSelection.collapsed(offset: prefix.length),
            );
    }

    // 2. Extract raw input after the prefix (+964 )
    String rawInput = newValue.text.substring(prefix.length);

    // 3. Filter for digits only
    String digitsOnly = rawInput.replaceAll(RegExp(r'\D'), '');

    // 4. Limit to 11 digits (generic max length for Iraq numbers including code)
    // usually it's 10 digits: 7XX XXX XXXX
    if (digitsOnly.length > 11) {
      digitsOnly = digitsOnly.substring(0, 11);
    }

    // 5. Apply Visual Mask: +964 XXX XXX XXXX
    StringBuffer buffer = StringBuffer(prefix);

    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    String result = buffer.toString();

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
