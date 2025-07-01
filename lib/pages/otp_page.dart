// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/login.dart';

// class OtpPopupScreen extends StatefulWidget {
//   final String email;
//   final bool visible;
//   final Function onClose;
//   final Function onSuccess;

//   const OtpPopupScreen({
//     super.key,
//     required this.email,
//     required this.visible,
//     required this.onClose,
//     required this.onSuccess,
//   });

//   @override
//   _OtpPopupScreenState createState() => _OtpPopupScreenState();
// }

// class _OtpPopupScreenState extends State<OtpPopupScreen> {
//   final TextEditingController _otpController = TextEditingController();
//   bool _loading = false;
//   bool _resendLoading = false;
//   int _timer = 60;
//   late Timer _countdownTimer;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.visible) {
//       _timer = 60; // Reset timer to 60 seconds when modal is opened
//       _startTimer(); // Start the countdown timer
//     }
//   }

//   @override
//   void dispose() {
//     if (_countdownTimer.isActive) {
//       _countdownTimer.cancel();
//     }
//     super.dispose();
//   }

//   void _startTimer() {
//     _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_timer > 0) {
//         setState(() {
//           _timer--;
//         });
//       } else {
//         _countdownTimer.cancel();
//       }
//     });
//   }

//   Future<void> _verifyOtp() async {
//     if (_otpController.text.isEmpty) {
//       _showAlert('Error', 'Please enter the OTP.');
//       return;
//     }

//     setState(() {
//       _loading = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/verify-otp'),
//         body: {'email': widget.email, 'otp': _otpController.text},
//       );

//       if (response.statusCode == 200) {
//         // widget.onSuccess();
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => LoginScreen()),
//         );
//       } else {
//         _showAlert('Error', 'Invalid OTP');
//       }
//     } catch (e) {
//       _showAlert('Error', 'Something went wrong. Please try again.');
//     } finally {
//       setState(() {
//         _loading = false;
//         _otpController.clear();
//       });
//     }
//   }

//   Future<void> _resendOtp() async {
//     setState(() {
//       _resendLoading = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('http://10.0.2.2:8000/api/resend-otp'),
//         body: {'email': widget.email},
//       );

//       if (response.statusCode == 200) {
//         _showAlert('Success', 'OTP has been resent to your email.');
//         setState(() {
//           _timer = 60;
//         });
//         _startTimer();
//       } else {
//         _showAlert('Error', 'Failed to resend OTP.');
//       }
//     } catch (e) {
//       _showAlert('Error', 'Something went wrong. Please try again.');
//     } finally {
//       setState(() {
//         _resendLoading = false;
//       });
//     }
//   }

//   void _showAlert(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.visible
//         ? AlertDialog(
//           backgroundColor: Colors.white, // Ensure background is white
//           contentPadding: EdgeInsets.all(20),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Close Icon
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: IconButton(
//                   icon: Icon(Icons.close, color: Colors.black),
//                   onPressed: () => widget.onClose(),
//                 ),
//               ),
//               Text(
//                 'Enter OTP',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'OTP has been sent to your email: ${widget.email}',
//                 style: TextStyle(fontSize: 16),
//               ),
//               SizedBox(height: 20),
//               TextField(
//                 controller: _otpController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: 'Enter OTP',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed:
//                     _otpController.text.isEmpty || _loading
//                         ? null
//                         : _verifyOtp, // Disable while loading or if OTP is empty
//                 child: Text(_loading ? 'Verifying...' : 'Verify OTP'),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed:
//                     _resendLoading || _timer > 0
//                         ? null
//                         : _resendOtp, // Disable if timer is > 0 or resend is loading
//                 child: Text(_timer > 0 ? 'Resend in $_timer s' : 'Resend Code'),
//               ),
//             ],
//           ),
//         )
//         : SizedBox();
//   }
// }
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/login.dart';

// class OtpPopupScreen extends StatefulWidget {
//   final String email;
//   final bool visible;
//   final VoidCallback onClose;
//   final VoidCallback onSuccess;

//   const OtpPopupScreen({
//     Key? key,
//     required this.email,
//     required this.visible,
//     required this.onClose,
//     required this.onSuccess,
//   }) : super(key: key);

//   @override
//   _OtpPopupScreenState createState() => _OtpPopupScreenState();
// }

// class _OtpPopupScreenState extends State<OtpPopupScreen> {
//   final List<TextEditingController> controllers =
//       List.generate(6, (_) => TextEditingController());
//   final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

//   bool _loading = false;
//   bool _resendLoading = false;
//   int _timer = 60;
//   Timer? _countdownTimer;

//   @override
//   void initState() {
//     super.initState();
//     _startCountdown();
//   }

//   @override
//   void dispose() {
//     _countdownTimer?.cancel();
//     for (var c in controllers) {
//       c.dispose();
//     }
//     for (var node in focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   void _startCountdown() {
//     _timer = 60;
//     _countdownTimer?.cancel();
//     _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_timer > 0) {
//         setState(() {
//           _timer--;
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   String get _otpText =>
//       controllers.map((controller) => controller.text).join();

//   Future<void> _verifyOtp() async {
//     if (_otpText.length != 6) {
//       _showAlert('Error', 'Please enter the 6-digit OTP.');
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/verify-otp'),
//         body: {'email': widget.email, 'otp': _otpText},
//       );

//       if (response.statusCode == 200) {
//         widget.onSuccess();
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => LoginScreen()),
//         );
//       } else {
//         _showAlert('Error', 'Invalid OTP');
//       }
//     } catch (e) {
//       _showAlert('Error', 'Something went wrong. Please try again.');
//     } finally {
//       setState(() => _loading = false);
//       for (var controller in controllers) {
//         controller.clear();
//       }
//     }
//   }

//   Future<void> _resendOtp() async {
//     setState(() => _resendLoading = true);

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/resend-otp'),
//         body: {'email': widget.email},
//       );

//       if (response.statusCode == 200) {
//         _showAlert('Success', 'OTP has been resent to your email.');
//         _startCountdown();
//       } else {
//         _showAlert('Error', 'Failed to resend OTP.');
//       }
//     } catch (e) {
//       _showAlert('Error', 'Something went wrong. Please try again.');
//     } finally {
//       setState(() => _resendLoading = false);
//     }
//   }

//   void _onDigitEntered(String value, int index) {
//     if (value.isNotEmpty && index < focusNodes.length - 1) {
//       FocusScope.of(context).requestFocus(focusNodes[index + 1]);
//     } else if (value.isEmpty && index > 0) {
//       FocusScope.of(context).requestFocus(focusNodes[index - 1]);
//     }
//   }

//   void _showAlert(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             child: Text('OK'),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Visibility(
//       visible: widget.visible,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               children: [
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: IconButton(
//                     icon: Icon(Icons.close),
//                     onPressed: widget.onClose,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Icon(Icons.mark_email_read, size: 50, color: Colors.orange),
//                 SizedBox(height: 16),
//                 Text(
//                   "Verify Your Email",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   "OTP has been sent to ${widget.email}",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey[700]),
//                 ),
//                 SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: List.generate(6, (index) {
//                     return SizedBox(
//                       width: 40,
//                       child: TextField(
//                         controller: controllers[index],
//                         focusNode: focusNodes[index],
//                         keyboardType: TextInputType.number,
//                         textAlign: TextAlign.center,
//                         maxLength: 1,
//                         decoration: InputDecoration(
//                           counterText: '',
//                           border: OutlineInputBorder(),
//                         ),
//                         onChanged: (value) => _onDigitEntered(value, index),
//                       ),
//                     );
//                   }),
//                 ),
//                 SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: _loading ? null : _verifyOtp,
//                   child: Text(_loading ? 'Verifying...' : 'Verify OTP'),
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: (_resendLoading || _timer > 0) ? null : _resendOtp,
//                   child: Text(_timer > 0
//                       ? 'Resend in $_timer s'
//                       : _resendLoading
//                           ? 'Resending...'
//                           : 'Resend Code'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// is code may background color white aa raha hai
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:plumber_project/pages/Apis.dart';
// import 'package:plumber_project/pages/login.dart';

// class OtpPopupScreen extends StatefulWidget {
//   final String email;
//   final bool visible;
//   final VoidCallback onClose;
//   final VoidCallback onSuccess;

//   const OtpPopupScreen({
//     Key? key,
//     required this.email,
//     required this.visible,
//     required this.onClose,
//     required this.onSuccess,
//   }) : super(key: key);

//   @override
//   _OtpPopupScreenState createState() => _OtpPopupScreenState();
// }

// class _OtpPopupScreenState extends State<OtpPopupScreen> {
//   final List<TextEditingController> controllers =
//       List.generate(6, (_) => TextEditingController());
//   final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

//   bool _loading = false;
//   bool _resendLoading = false;
//   int _timer = 60;
//   Timer? _countdownTimer;

//   @override
//   void initState() {
//     super.initState();
//     _startCountdown();
//   }

//   @override
//   void dispose() {
//     _countdownTimer?.cancel();
//     for (var c in controllers) {
//       c.dispose();
//     }
//     for (var node in focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   void _startCountdown() {
//     _timer = 60;
//     _countdownTimer?.cancel();
//     _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_timer > 0) {
//         setState(() {
//           _timer--;
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   String get _otpText => controllers.map((c) => c.text.trim()).join();

//   Future<void> _verifyOtp() async {
//     if (_otpText.length != 6) {
//       _showAlert('Error', 'Please enter the 6-digit OTP.');
//       return;
//     }

//     setState(() => _loading = true);

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/verify-otp'),
//         body: {
//           'email': widget.email,
//           'otp': _otpText,
//         },
//       );

//       if (response.statusCode == 200) {
//         // widget.onSuccess();
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => LoginScreen()),
//         );
//       } else {
//         _showAlert('Error', 'Invalid OTP or expired.');
//       }
//     } catch (e) {
//       _showAlert('Error', 'Something went wrong. Please try again.');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   Future<void> _resendOtp() async {
//     setState(() => _resendLoading = true);

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/resend-otp'),
//         body: {'email': widget.email},
//       );

//       if (response.statusCode == 200) {
//         _showAlert('Success', 'OTP has been resent to your email.');
//         _startCountdown();
//       } else {
//         _showAlert('Error', 'Failed to resend OTP.');
//       }
//     } catch (e) {
//       _showAlert('Error', 'Something went wrong. Please try again.');
//     } finally {
//       setState(() => _resendLoading = false);
//     }
//   }

//   void _onDigitEntered(String value, int index) {
//     if (value.isNotEmpty && index < focusNodes.length - 1) {
//       FocusScope.of(context).requestFocus(focusNodes[index + 1]);
//     } else if (value.isEmpty && index > 0) {
//       FocusScope.of(context).requestFocus(focusNodes[index - 1]);
//     }
//   }

//   void _showAlert(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             child: Text('OK'),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Visibility(
//       visible: widget.visible,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               children: [
//                 Align(
//                   alignment: Alignment.topLeft,
//                   child: IconButton(
//                     icon: Icon(Icons.close),
//                     onPressed: widget.onClose,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Icon(Icons.mark_email_read, size: 50, color: Colors.orange),
//                 SizedBox(height: 16),
//                 Text(
//                   "Verify Your Email",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   "OTP has been sent to ${widget.email}",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey[700]),
//                 ),
//                 SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: List.generate(6, (index) {
//                     return SizedBox(
//                       width: 40,
//                       child: TextField(
//                         controller: controllers[index],
//                         focusNode: focusNodes[index],
//                         keyboardType: TextInputType.number,
//                         textAlign: TextAlign.center,
//                         maxLength: 1,
//                         decoration: InputDecoration(
//                           counterText: '',
//                           border: OutlineInputBorder(),
//                         ),
//                         onChanged: (value) => _onDigitEntered(value, index),
//                       ),
//                     );
//                   }),
//                 ),
//                 SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: _loading ? null : _verifyOtp,
//                   child: Text(_loading ? 'Verifying...' : 'Verify OTP'),
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: (_resendLoading || _timer > 0) ? null : _resendOtp,
//                   child: Text(_timer > 0
//                       ? 'Resend in $_timer s'
//                       : _resendLoading
//                           ? 'Resending...'
//                           : 'Resend Code'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/login.dart';

class OtpPopupScreen extends StatefulWidget {
  final String email;
  final bool visible;
  final VoidCallback onClose;
  final VoidCallback onSuccess;

  const OtpPopupScreen({
    Key? key,
    required this.email,
    required this.visible,
    required this.onClose,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _OtpPopupScreenState createState() => _OtpPopupScreenState();
}

class _OtpPopupScreenState extends State<OtpPopupScreen> {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _resendLoading = false;
  int _timer = 60;
  Timer? _countdownTimer;

  final Color darkBlue = Color(0xFF003E6B);
  final Color tealBlue = Color(0xFF00A8A8);

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var c in controllers) {
      c.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timer > 0) {
        setState(() {
          _timer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpText => controllers.map((c) => c.text.trim()).join();

  Future<void> _verifyOtp() async {
    if (_otpText.length != 6) {
      _showAlert('Error', 'Please enter the 6-digit OTP.');
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/verify-otp'),
        body: {
          'email': widget.email,
          'otp': _otpText,
        },
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        _showAlert('Error', 'Invalid OTP or expired.');
      }
    } catch (e) {
      _showAlert('Error', 'Something went wrong. Please try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _resendLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/resend-otp'),
        body: {'email': widget.email},
      );

      if (response.statusCode == 200) {
        _showAlert('Success', 'OTP has been resent to your email.');
        _startCountdown();
      } else {
        _showAlert('Error', 'Failed to resend OTP.');
      }
    } catch (e) {
      _showAlert('Error', 'Something went wrong. Please try again.');
    } finally {
      setState(() => _resendLoading = false);
    }
  }

  void _onDigitEntered(String value, int index) {
    if (value.isNotEmpty && index < focusNodes.length - 1) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: Scaffold(
        backgroundColor: darkBlue,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ),
                SizedBox(height: 20),
                Icon(Icons.mark_email_read, size: 50, color: tealBlue),
                SizedBox(height: 16),
                Text(
                  "Verify Your Email",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  "OTP has been sent to ${widget.email}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 40,
                      child: TextField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white10,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: tealBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: tealBlue, width: 2),
                          ),
                        ),
                        onChanged: (value) => _onDigitEntered(value, index),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _loading ? null : _verifyOtp,
                  child: Text(_loading ? 'Verifying...' : 'Verify OTP'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: darkBlue,
                  ),
                  onPressed: (_resendLoading || _timer > 0) ? null : _resendOtp,
                  child: Text(_timer > 0
                      ? 'Resend in $_timer s'
                      : _resendLoading
                          ? 'Resending...'
                          : 'Resend Code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
