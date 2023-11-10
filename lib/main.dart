import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class User {
  final String name;
  final String email;
  final String domain;
  final String gender;
  final bool available;

  User({
    required this.name,
    required this.email,
    required this.domain,
    required this.gender,
    required this.available,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late List<User> allUsers;
  List<User> displayedUsers = [];
  final TextEditingController searchController = TextEditingController();
  final Set<String> selectedDomains = Set();
  final Set<String> selectedGenders = Set();
  bool isAvailable = false;
  final Set<String> selectedTeamMembers = Set();
  final int usersPerPage = 10;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Populate the user list with dummy data
    allUsers = List.generate(
      100, // replace with your actual user data or API call
      (index) => User(
        name: 'User $index',
        email: 'user$index@example.com',
        domain: index % 2 == 0 ? 'Marketing' : 'Engineering',
        gender: index % 2 == 0 ? 'Female' : 'Male',
        available: index % 3 == 0,
      ),
    );

    // Initial display of users
    _updateDisplayedUsers();
  }

  void _updateDisplayedUsers() {
    final start = currentPage * usersPerPage;
    final end = (currentPage + 1) * usersPerPage;
    displayedUsers =
        allUsers.sublist(start, end > allUsers.length ? allUsers.length : end);

    // Apply filters
    displayedUsers = displayedUsers
        .where((user) =>
            (selectedDomains.isEmpty ||
                selectedDomains.contains(user.domain)) &&
            (selectedGenders.isEmpty ||
                selectedGenders.contains(user.gender)) &&
            (!isAvailable || user.available))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                _filterUsers(value);
              },
              decoration: InputDecoration(
                labelText: 'Search by Name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          _buildFilterSection(),
          Expanded(
            child: ListView.builder(
              itemCount: displayedUsers.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(displayedUsers[index].name),
                    subtitle: Text(displayedUsers[index].email),
                    tileColor: selectedTeamMembers
                            .contains(displayedUsers[index].email)
                        ? Colors.green[100]
                        : null,
                    onTap: () {
                      _addToTeam(displayedUsers[index]);
                    },
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: currentPage > 0 ? () => _changePage(-1) : null,
                child: Text('Previous'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: currentPage < allUsers.length ~/ usersPerPage
                    ? () => _changePage(1)
                    : null,
                child: Text('Next'),
              ),
            ],
          ),
          _buildAddToTeamButton(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDomainFilter(),
          _buildGenderFilter(),
          _buildAvailabilityFilter(),
        ],
      ),
    );
  }

  Widget _buildDomainFilter() {
    return DropdownButton<String>(
      value: selectedDomains.isNotEmpty ? selectedDomains.first : null,
      hint: Text('Select Domain'),
      onChanged: (value) {
        setState(() {
          selectedDomains.toggle(value!);
          _updateDisplayedUsers();
        });
      },
      items: ['Marketing', 'Engineering']
          .map((domain) => DropdownMenuItem<String>(
                value: domain,
                child: Text(domain),
              ))
          .toList(),
    );
  }

  Widget _buildGenderFilter() {
    return DropdownButton<String>(
      value: selectedGenders.isNotEmpty ? selectedGenders.first : null,
      hint: Text('Select Gender'),
      onChanged: (value) {
        setState(() {
          selectedGenders.toggle(value!);
          _updateDisplayedUsers();
        });
      },
      items: ['Male', 'Female']
          .map((gender) => DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              ))
          .toList(),
    );
  }

  Widget _buildAvailabilityFilter() {
    return Row(
      children: [
        Text('Available'),
        Checkbox(
          value: isAvailable,
          onChanged: (value) {
            setState(() {
              isAvailable = value!;
              _updateDisplayedUsers();
            });
          },
        ),
      ],
    );
  }

  Widget _buildAddToTeamButton() {
    return ElevatedButton(
      onPressed: () {
        _createTeam();
      },
      child: Text('Add To Team'),
    );
  }

  void _filterUsers(String searchTerm) {
    setState(() {
      currentPage = 0;
      displayedUsers = allUsers
          .where((user) =>
              user.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
      _updateDisplayedUsers();
    });
  }

  void _changePage(int delta) {
    setState(() {
      currentPage += delta;
      _updateDisplayedUsers();
    });
  }

  void _addToTeam(User user) {
    if (user.available) {
      setState(() {
        selectedTeamMembers.add(user.email);
      });
    }
  }

  void _createTeam() {
    if (selectedTeamMembers.isNotEmpty) {
      // Filter selected users by unique domains
      Set<String> uniqueDomains = Set();
      List<User> teamMembers = [];

      for (User user in allUsers) {
        if (selectedTeamMembers.contains(user.email) && user.available) {
          if (uniqueDomains.add(user.domain)) {
            teamMembers.add(user);
          }
        }
      }

      // Navigate to the Team Details screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TeamDetailsScreen(teamMembers: teamMembers)),
      );

      // Clear selected team members
      setState(() {
        selectedTeamMembers.clear();
      });
    }
  }
}

class TeamDetailsScreen extends StatelessWidget {
  final List<User> teamMembers;

  TeamDetailsScreen({required this.teamMembers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Details'),
      ),
      body: ListView.builder(
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(teamMembers[index].name),
            subtitle: Text(teamMembers[index].email),
          );
        },
      ),
    );
  }
}

extension SetToggle on Set<String> {
  void toggle(String value) {
    if (contains(value)) {
      remove(value);
    } else {
      add(value);
    }
  }
}
