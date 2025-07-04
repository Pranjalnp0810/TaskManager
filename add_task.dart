import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyAddTask extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? task;
  const MyAddTask({super.key, this.task, this.isEdit = false});

  @override
  State<MyAddTask> createState() => _MyAddTaskState();
}

class _MyAddTaskState extends State<MyAddTask> {
  final _formKey = GlobalKey<FormState>();
  String? selectedUser;
  List<Map<String, dynamic>> users = [];
  final List<String> statusOptions = ['pending', 'done', 'snoozed'];
  String? selectedStatus;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _deadlineController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    if (widget.isEdit && widget.task != null) {
      final task = widget.task!;
      _titleController.text = task['title'] ?? '';
      selectedUser = task['assigned_to'];
      selectedStatus = task['status'];
      _deadlineController.text = task['deadline'] ?? '';
      _descriptionController.text = task['description'] ?? '';
    }
  }

  Future<void> fetchUsers() async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select('id, email, name');
    setState(() {
      users = List<Map<String, dynamic>>.from(response);
    });
    print('Fetched users: $users');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          widget.isEdit ? "Edit Task" : "Add Task",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
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
                  DropdownButtonFormField<String>(
                    value: selectedUser,
                    items:
                        users.map((user) {
                          return DropdownMenuItem<String>(
                            value: user['id'].toString(),
                            child: Text(user['name']),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUser = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
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
                    controller: _deadlineController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        String formattedDate =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        _deadlineController.text = formattedDate;
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Select deadline date";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Deadline",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (widget.isEdit && widget.task != null) {
                          final taskId = widget.task!['id'];
                          try {
                            print("Updating task $taskId");
                            await Supabase.instance.client
                                .from('tasks')
                                .update({
                                  'title': _titleController.text.trim(),
                                  'assigned_to': selectedUser,
                                  'status': selectedStatus,
                                  'deadline': _deadlineController.text.trim(),
                                  'description':
                                      _descriptionController.text.trim(),
                                })
                                .eq('id', taskId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Task Updated Successfully"),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            print("Update error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error Updating your Task"),
                              ),
                            );
                          }
                        } else {
                          final currentUser =
                              Supabase.instance.client.auth.currentUser;
                          try {
                            await Supabase.instance.client.from('tasks').insert(
                              {
                                'user_id': selectedUser,
                                'title': _titleController.text.trim(),
                                'assigned_to': selectedUser,
                                'status': selectedStatus,
                                'deadline': _deadlineController.text.trim(),
                                'description':
                                    _descriptionController.text.trim(),
                                'created_at': DateTime.now().toIso8601String(),
                                'created_by': currentUser!.id,
                              },
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Task created successfully"),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            print("Insert error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error creating task")),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 4,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      widget.isEdit ? "Edit Task" : "Create Task",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
