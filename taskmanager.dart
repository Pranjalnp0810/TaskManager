import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_manager/add_task.dart';
import 'package:task_manager/signin.dart';

class MyTaskManager extends StatefulWidget {
  const MyTaskManager({super.key});

  @override
  State<MyTaskManager> createState() => _MyTaskManagerState();
}

class _MyTaskManagerState extends State<MyTaskManager>
    with SingleTickerProviderStateMixin {
  TableRow rowInfo(
    String label,
    String value, {
    Color? valueColor,
    TextStyle? textStyle,
    bool isHeader = false,
    Color? backgroundColor,
  }) {
    return TableRow(
      children: [
        Container(
          color: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: textStyle ?? const TextStyle(fontSize: 16),
            ),
          ),
        ),
        Container(
          color: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style:
                  textStyle?.copyWith(color: valueColor) ??
                  TextStyle(fontSize: 16, color: valueColor ?? Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  String formatDate(String iso) {
    try {
      final date = DateTime.parse(iso);
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } catch (e) {
      return iso;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTasks(
    String status, {
    String? assignedToUserId,
  }) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (currentUserId == null) {
      throw Exception("User not authenticated");
    }

    final assignedId = assignedToUserId ?? currentUserId;

    print("Fetching tasks assigned to: $assignedId");

    final response = await Supabase.instance.client
        .from('tasks')
        .select('*, profiles!assigned_to(name)')
        .eq('status', status)
        .eq('assigned_to', assignedId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updatetaskStatus(dynamic taskId, String newStatus) async {
    try {
      print("Updating task $taskId to status $newStatus");

      final response =
          await Supabase.instance.client
              .from('tasks')
              .update({'status': newStatus})
              .eq('id', taskId)
              .select();

      print("Update task: $response");

      if (response == null || response.isEmpty) {
        print("No task updated. ID might be incorrect.");
      } else {
        print("Task updated successfully.");
      }
    } catch (e) {
      print("Error updating task: $e");
    }
  }

  Future<void> deleteTask(dynamic taskId) async {
    try {
      print("Trying to delete task with ID: $taskId");

      final response =
          await Supabase.instance.client
              .from('tasks')
              .delete()
              .eq('id', taskId)
              .select();
      if (response.isEmpty) {
        print("No task was deleted. Task ID may not exist.");
      } else {
        print("Task deleted successfully");
      }
    } catch (e) {
      print("Exception deleting task: $e");
    }
  }

  String? selectedUser;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select('id, name')
        .order('name', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> loadUsers() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;

      final fetchedUsers = await fetchUsers();

      final currentUser = fetchedUsers.firstWhere(
        (user) => user['id'] == currentUserId,
        orElse: () => <String, dynamic>{},
      );

      setState(() {
        users = fetchedUsers;
        selectedUser = currentUser['id'] as String?;
      });
    } catch (e) {
      print("Error loading users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.blue,
          title: Text("Task Manager", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  Supabase.instance.client.auth.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MySignIn()),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                child: FutureBuilder(
                  future: fetchUsers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();

                    final userList = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Filtered by User",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      value: selectedUser,
                      items:
                          userList.map((user) {
                            return DropdownMenuItem<String>(
                              value: user['id'],
                              child: Text(user['name']),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUser = value;
                        });
                      },
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Colors.blue[400],
                  borderRadius: BorderRadius.circular(15),
                ),

                child: TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: -8,
                  ),
                  tabs: [
                    Tab(text: "Pending"),
                    Tab(text: "Done"),
                    Tab(text: "Snoozed"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    taskListTab("pending", selectedUser),
                    taskListTab("done", selectedUser),
                    taskListTab("snoozed", selectedUser),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyAddTask()),
            );
            if (result != null) {
              setState(() {});
            }
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget taskListTab(String status, String? userId) {
    print('Filtering Tasks Assigned to: $userId');
    print('Signed-in User: ${Supabase.instance.client.auth.currentUser?.id}');

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchTasks(status, assignedToUserId: userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No tasks found"));
        }

        final tasks = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyAddTask(isEdit: true, task: task),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: taskCard(task),
              );
            },
          ),
        );
      },
    );
  }

  Widget taskCard(Map task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {0: FlexColumnWidth(0.5), 1: FlexColumnWidth(1)},
          children: [
            TableRow(
              children: [
                Container(
                  color: Colors.blue[50],
                  padding: const EdgeInsets.symmetric(
                    vertical: 23,
                    horizontal: 8,
                  ),
                  child: Text(
                    "Title",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  color: Colors.blue[50],
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${task['title']}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text("Delete Task"),
                                    content: Text(
                                      "Are you sure you want to delete this task?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: Text("Delete"),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirm == true) {
                              await deleteTask(task['id']);
                              setState(() {});
                            }
                          } else {
                            await updatetaskStatus(task['id'], value);
                            setState(() {});
                          }
                          setState(() {});
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'pending',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.pending_actions,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 6),
                                    Text('Pending'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'done',
                                enabled: task['status'] != 'done',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.done,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 6),
                                    Text('Done'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'snoozed',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.snooze,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 6),
                                    Text('Snooze'),
                                  ],
                                ),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        icon: Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            rowInfo(
              "Assign to:",
              task['profiles']?['name'] ?? 'Unknown',
              backgroundColor: Colors.white,
            ),
            rowInfo(
              "Created on:",
              formatDate(task['created_at']),
              valueColor: Colors.green,
              backgroundColor: Colors.white,
            ),
            rowInfo(
              "Due date:",
              formatDate(task['deadline']),
              valueColor: Colors.red,
              backgroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
