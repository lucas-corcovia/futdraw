import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Formatter {
  static final realInputFormatter = MaskTextInputFormatter(
    mask: '#,##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
}
