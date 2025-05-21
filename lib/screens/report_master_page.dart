import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:x_ray_entry_app/modals/xray_entry_sheet_data.dart';
import 'package:x_ray_entry_app/services/firebase_service.dart';

class ReportMasterPage extends StatefulWidget {
  const ReportMasterPage({super.key});

  @override
  State<ReportMasterPage> createState() => _ReportMasterPageState();
}

class _ReportMasterPageState extends State<ReportMasterPage> {
  final FirebaseService _xrayService = FirebaseService();
  final TextEditingController _gmdController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _specificDate;
  String _searchType = 'date'; // 'date', 'specificDate', or 'gmd'
  bool _isLoading = false;
  bool _hasSearched = false; // add this flag to track if search was performed

  @override
  void dispose() {
    _gmdController.dispose();
    _patientNameController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context,
      {bool isStartDate = false,
      bool isEndDate = false,
      bool isSpecificDate = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isSpecificDate
          ? _specificDate ?? DateTime.now()
          : isStartDate
              ? _startDate ?? DateTime.now()
              : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isSpecificDate) {
          _specificDate = picked;
        } else if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _searchEntries() {
    setState(() {
      _isLoading = true;
      _hasSearched = true; // set this flag when search is performed
    });
    // Delay to show loading state
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Widget _buildDateRangeSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, isStartDate: true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startDate != null
                        ? DateFormat('dd-MM-yyyy').format(_startDate!)
                        : 'Select start date',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, isEndDate: true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _endDate != null
                        ? DateFormat('dd-MM-yyyy').format(_endDate!)
                        : 'Select end date',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed:
              (_startDate != null && _endDate != null) ? _searchEntries : null,
          child: const Text('Search by Date Range'),
        ),
      ],
    );
  }

  Widget _buildSpecificDateSelector() {
    return Column(
      children: [
        InkWell(
          onTap: () => _selectDate(context, isSpecificDate: true),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Select Date',
              border: OutlineInputBorder(),
            ),
            child: Text(
              _specificDate != null
                  ? DateFormat('dd-MM-yyyy').format(_specificDate!)
                  : 'Select a date',
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _specificDate != null ? _searchEntries : null,
          child: const Text('Search by Specific Date'),
        ),
      ],
    );
  }

  Widget _buildGmdSearch() {
    return Column(
      children: [
        TextField(
          controller: _gmdController,
          decoration: const InputDecoration(
            labelText: 'GMD Number',
            border: OutlineInputBorder(),
            hintText: 'Enter GMD number',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            // This will trigger a rebuild when text changes
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _gmdController.text.isNotEmpty && _isValidGmdNumber()
              ? _searchEntries
              : null,
          child: const Text('Search by GMD'),
        ),
      ],
    );
  }

  Widget _buildPatientNameSearch() {
    return Column(
      children: [
        TextField(
          controller: _patientNameController,
          decoration: const InputDecoration(
            labelText: 'Patient Name',
            border: OutlineInputBorder(),
            hintText: 'Enter patient name',
          ),
          onChanged: (value) {
            // This will trigger a rebuild when text changes
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed:
              _patientNameController.text.isNotEmpty ? _searchEntries : null,
          child: const Text('Search by Patient Name'),
        ),
      ],
    );
  }

  Widget _buildMobileNumberSearch() {
    return Column(
      children: [
        TextField(
          controller: _mobileNumberController,
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            border: OutlineInputBorder(),
            hintText: 'Enter mobile number',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            // This will trigger a rebuild when text changes
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed:
              _mobileNumberController.text.isNotEmpty ? _searchEntries : null,
          child: const Text('Search by Mobile No.'),
        ),
      ],
    );
  }

  // helper function to validate GMD number
  bool _isValidGmdNumber() {
    if (_gmdController.text.isEmpty) return false;
    // check if it's a valid number
    return int.tryParse(_gmdController.text) != null;
  }

  // dropdown for search by
  Widget _buildSearchTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Text('Search by:'),
          const SizedBox(width: 16),
          Expanded(
              child: DropdownButtonFormField<String>(
            value: _searchType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: const [
              DropdownMenuItem(
                value: 'date',
                child: Text('Date Range'),
              ),
              DropdownMenuItem(
                value: 'specificDate',
                child: Text('Specific Date'),
              ),
              DropdownMenuItem(
                value: 'gmd',
                child: Text('GMD Number'),
              ),
              DropdownMenuItem(
                value: 'patient',
                child: Text('Patient Name'),
              ),
              DropdownMenuItem(
                value: 'mobile',
                child: Text('Mobile Number'),
              ),
            ],
            onChanged: (String? value) {
              setState(() {
                _searchType = value!;
              });
            },
          )),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (!_hasSearched) {
      // show nothing or a prompt until the user performs a search
      return const Center(child: Text('Perform a seach to view reports'));
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchType == 'date' && (_startDate == null || _endDate == null)) {
      return const Center(child: Text('Select a date range to view reports'));
    }

    if (_searchType == 'specificDate' && _specificDate == null) {
      return const Center(child: Text('Select a date to view reports'));
    }

    if (_searchType == 'gmd' && _gmdController.text.isEmpty) {
      return const Center(child: Text('Enter a GMD number to search'));
    }

    if (_searchType == 'patient' && _patientNameController.text.isEmpty) {
      return const Center(
        child: Text('Enter a Patient Name to search'),
      );
    }

    if (_searchType == 'mobile' && _mobileNumberController.text.isEmpty) {
      return const Center(
        child: Text('Enter a Mobile Number to search'),
      );
    }

    return Expanded(
      child: StreamBuilder<List<XrayEntrySheetData>>(
        stream: _searchType == 'date'
            ? _xrayService.getEntriesByDateRange(
                startDate: _startDate!,
                endDate: _endDate!,
              )
            : _searchType == 'specificDate'
                ? _xrayService.getEntriesByDateRange(
                    startDate: _specificDate!,
                    endDate: DateTime(
                      _specificDate!.year,
                      _specificDate!.month,
                      _specificDate!.day,
                      23,
                      59,
                      59,
                    ),
                  )
                : _searchType == 'gmd'
                    ? _xrayService
                        .getEntriesByGmdNumber(int.parse(_gmdController.text))
                    : _searchType == 'mobile'
                        ? _xrayService.getEntriesByMobileNumber(
                            _mobileNumberController.text)
                        : _xrayService.getEntriesByPatientName(
                            _patientNameController.text),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data!;

          if (entries.isEmpty) {
            return const Center(child: Text('No entries found'));
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Center(
                    child: Text(
                      entry.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GMD No.: ${entry.gmdNo}'),
                      Text('Part of X-Ray: ${entry.partOfXray}'),
                      Text('Mobile No.: ${entry.mobileNumber}'),
                      Text('Age: ${entry.age}'),
                      Text('Sex: ${entry.sex}'),
                      Text('Doctor Name: ${entry.doctorName}'),
                      Text('Payment Type: ${entry.paymentType}'),
                      Text('Location Name: ${entry.locationName}'),
                      Text(
                          'Reference Person Name: ${entry.referencePersonName}'),
                      Text('Paid/Due: ${entry.paidOrDue}'),
                      Text(
                          'Date: ${DateFormat('dd-MM-yyyy HH:mm').format(entry.timestamp.toDate())}'),
                    ],
                  ),
                  trailing: Text('₹${entry.referenceFee.toString()}'),
                  onTap: () {
                    // Navigate to detail view if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('X-Ray Reports'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchTypeDropdown(),
            _searchType == 'date'
                ? _buildDateRangeSelector()
                : _searchType == 'specificDate'
                    ? _buildSpecificDateSelector()
                    : _searchType == 'gmd'
                        ? _buildGmdSearch()
                        : _searchType == 'mobile'
                            ? _buildMobileNumberSearch()
                            : _buildPatientNameSearch(),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              'Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _buildResultsSection(),
          ],
        ),
      ),
    );
  }
}
