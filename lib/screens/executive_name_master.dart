import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:x_ray_entry_app/authentication/auth_provider.dart';
import 'package:x_ray_entry_app/modals/executive_name_data.dart';
import 'package:x_ray_entry_app/services/firebase_service.dart';

class ExecutiveNameMaster extends StatefulWidget {
  const ExecutiveNameMaster(
      {super.key, this.mobileNumber, this.isDisplayMode = false});

  final String? mobileNumber;
  final bool isDisplayMode;

  @override
  State<ExecutiveNameMaster> createState() => _ExecutiveNameMasterState();
}

class _ExecutiveNameMasterState extends State<ExecutiveNameMaster> {
  final FirebaseService firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  bool _obsecureText = true; // initially password is hidden

  final TextEditingController executiveNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  bool _isSubmitting = false;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUpdateMode = false; // track update we're in update for view password

  ExecutiveNameData? _executiveNameData;
  String? executiveMobileNumberFromArgs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          executiveMobileNumberFromArgs = args;
          _isEditing =
              !widget.isDisplayMode; // only editing if not in display mode
          _isUpdateMode = !widget.isDisplayMode;
        });
        _fetchExecutiveData(args);
      } else if (widget.mobileNumber != null) {
        setState(() {
          executiveMobileNumberFromArgs = widget.mobileNumber;
          _isEditing = !widget.isDisplayMode;
          _isUpdateMode = !widget.isDisplayMode;
        });
        _fetchExecutiveData(widget.mobileNumber!);
      }
    });
  }

  Future<void> _fetchExecutiveData(String mobileNumber) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data =
          await firebaseService.getExecutiveByMobileNumber(mobileNumber);
      if (data != null) {
        setState(() {
          _executiveNameData = data;
          executiveNameController.text = data.executiveName;
          mobileNumberController.text = data.mobileNumber;
          emailController.text = data.email;
          passwordController.text = data.password;
          statusController.text = data.status;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        // only create acctount if not in update mode
        if (!_isUpdateMode) {
          await authProvider.createAccount(
            username: executiveNameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            isAdmin: false,
          );
        }

        final updatedExecutiveData = ExecutiveNameData(
          executiveName: executiveNameController.text.trim(),
          mobileNumber: mobileNumberController.text.trim(),
          email: emailController.text.trim(),
          password: _isUpdateMode
              ? _executiveNameData!.password // keep original password
              : passwordController.text
                  .trim(), // new password in create mode only
          status: statusController.text.trim(),
          timestamp: _executiveNameData?.timestamp ?? Timestamp.now(),
        );

        final success = _isEditing
            ? await firebaseService.updateExecutiveData(
                _executiveNameData!.mobileNumber, updatedExecutiveData)
            : await firebaseService.addExecutiveNameData(updatedExecutiveData);

        setState(() => _isSubmitting = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? (_isEditing ? 'Executive Updated!' : 'Executive added!')
                  : 'Operation failed. Mobile Number might be already in use.'),
            ),
          );

          if (success && _isEditing) {
            Navigator.pop(context, true); // return to previous screen
          } else if (success && !_isEditing) {
            executiveNameController.clear();
            mobileNumberController.clear();
            emailController.clear();
            passwordController.clear();
            statusController.clear();
          }
        }
      } on FirebaseException catch (e) {
        String errorMessage = 'Registration failed';
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Email already in use';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
          default:
            errorMessage = e.message ?? errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  void dispose() {
    executiveNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isDisplayMode
            ? 'Executive Mobile No. Details: ${executiveMobileNumberFromArgs ?? ''}'
            : _isEditing
                ? 'Edit Executive: ${executiveMobileNumberFromArgs ?? ''}'
                : 'Executive Master'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: widget.isDisplayMode
                  ? _buildDisplayView()
                  : _buildEditView(authProvider),
            ),
    );
  }

  Widget _buildDisplayView() {
    if (_executiveNameData == null) {
      return const Center(
        child: Text('No Executive Data'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'current Executive Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Executive Name: ${_executiveNameData!.executiveName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mobile Number: ${_executiveNameData!.mobileNumber}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${_executiveNameData!.email}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${_executiveNameData!.status}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: ${_executiveNameData!.timestamp.toDate()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditView(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing && _executiveNameData != null) ...[
              const Text(
                'Edit Executive Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ] else
              const Text(
                'Add New Executive Information',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            const SizedBox(height: 30),
            TextFormField(
              controller: executiveNameController,
              decoration: InputDecoration(
                labelText: 'Executive Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: 'Enter executive name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a executive name';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: mobileNumberController,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: 'Enter mobile number',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email ID',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: 'Enter email id.',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a email id.';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            Stack(
              children: [
                TextFormField(
                  controller: passwordController,
                  obscureText: _obsecureText,
                  readOnly: _isUpdateMode, // Make read-only in edit mode
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    hintText: 'Enter password',
                  ),
                  validator: (value) {
                    if (!_isUpdateMode) {
                      // Only validate in create mode
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'Password must contain at least one uppercase letter';
                      }
                      if (!value.contains(RegExp(r'[a-z]'))) {
                        return 'Password must contain at least one lowercase letter';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Password must contain at least one digit';
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}<>]'))) {
                        return 'Password must contain at least one special character';
                      }
                    }
                    return null;
                  },
                ),
                if (_isUpdateMode)
                  Positioned(
                    right: 10,
                    top: 15,
                    child: IconButton(
                      icon: Icon(_obsecureText
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obsecureText = !_obsecureText;
                        });
                      },
                    ),
                  ),
              ],
            ),
            if (_isUpdateMode)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'Password cannot be changed here',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: statusController.text.isEmpty
                  ? 'active'
                  : statusController.text,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: ['active', 'inactive']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  statusController.text = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a status';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            if (!authProvider.isExecutive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade700,
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEditing ? 'Update' : 'Submit',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
