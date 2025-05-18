import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/login.dart';

class OtpPopupScreen extends StatefulWidget {
  final String email;
  final bool visible;
  final Function onClose;
  final Function onSuccess;

  const OtpPopupScreen({
    super.key,
    required this.email,
    required this.visible,
    required this.onClose,
    required this.onSuccess,
  });

  @override
  _OtpPopupScreenState createState() => _OtpPopupScreenState();
}

class _OtpPopupScreenState extends State<OtpPopupScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;
  bool _resendLoading = false;
  int _timer = 60;
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      _timer = 60; // Reset timer to 60 seconds when modal is opened
      _startTimer(); // Start the countdown timer
    }
  }

  @override
  void dispose() {
    if (_countdownTimer.isActive) {
      _countdownTimer.cancel();
    }
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timer > 0) {
        setState(() {
          _timer--;
        });
      } else {
        _countdownTimer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      _showAlert('Error', 'Please enter the OTP.');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/verify-otp'),
        body: {'email': widget.email, 'otp': _otpController.text},
      );

      if (response.statusCode == 200) {
        // widget.onSuccess();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        _showAlert('Error', 'Invalid OTP');
      }
    } catch (e) {
      _showAlert('Error', 'Something went wrong. Please try again.');
    } finally {
      setState(() {
        _loading = false;
        _otpController.clear();
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _resendLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/resend-otp'),
        body: {'email': widget.email},
      );

      if (response.statusCode == 200) {
        _showAlert('Success', 'OTP has been resent to your email.');
        setState(() {
          _timer = 60;
        });
        _startTimer();
      } else {
        _showAlert('Error', 'Failed to resend OTP.');
      }
    } catch (e) {
      _showAlert('Error', 'Something went wrong. Please try again.');
    } finally {
      setState(() {
        _resendLoading = false;
      });
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.visible
        ? AlertDialog(
          backgroundColor: Colors.white, // Ensure background is white
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Icon
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () => widget.onClose(),
                ),
              ),
              Text(
                'Enter OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'OTP has been sent to your email: ${widget.email}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _otpController.text.isEmpty || _loading
                        ? null
                        : _verifyOtp, // Disable while loading or if OTP is empty
                child: Text(_loading ? 'Verifying...' : 'Verify OTP'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _resendLoading || _timer > 0
                        ? null
                        : _resendOtp, // Disable if timer is > 0 or resend is loading
                child: Text(_timer > 0 ? 'Resend in $_timer s' : 'Resend Code'),
              ),
            ],
          ),
        )
        : SizedBox();
  }
}
