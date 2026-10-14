import 'package:flutter/services.dart';

/// 半角英字キーボードに固定する [TextInputType](英単語・英例文・検索の入力欄で使う)。
///
/// 日本語 IME などに切り替えられないようにするためのもの。
/// **visiblePassword でなければならない**: Flutter の iOS 実装
/// (ToUIKeyboardType)で UIKeyboardTypeASCIICapable にマップされるのは
/// これだけで、text は UIKeyboardTypeDefault(地球儀キーでかなに切替可)、
/// emailAddress / url は ASCII だが @ や .com キーが出る。
/// 入力内容を隠す指定ではない(obscureText は別)。
const TextInputType asciiKeyboardType = TextInputType.visiblePassword;
