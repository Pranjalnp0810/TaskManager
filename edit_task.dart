import 'package:flutter/material.dart';

class MyEditTask extends StatefulWidget {
  const MyEditTask({super.key});

  @override
  State<MyEditTask> createState() => _MyEditTaskState();
}

class _MyEditTaskState extends State<MyEditTask> {
  final _formKey = GlobalKey<FormState>();
  final List<String> statusOptions = ['Pending', 'Done', 'Snoozed'];
  String? selectedStatus;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _assignController = TextEditingController();
  TextEditingController _deadlineController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Add task", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Input Title";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _assignController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Select user";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Assigned to",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  value: selectedStatus,
                  items:
                      statusOptions
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                  validator: (value) => value == null ? selectedStatus : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Select deadline date";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Deadline",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter task description";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print("Title: ${_titleController.text}");
                      print("Assigned to: ${_assignController.text}");
                      print("Status: $selectedStatus");
                      print("Deadline: ${_deadlineController.text}");
                      print("Description: ${_descriptionController.text}");

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Task created successfully")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 4,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    "Create Task",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
