class RoleHelper {
  static bool isAdmin(String role) => role == 'Admin';
  static bool isManager(String role) => role == 'Admin' || role == 'Manager';
  static bool isFarmer(String role) =>
      role == 'Admin' || role == 'Manager' || role == 'Farmer';
  static bool isViewer(String role) => true; // todos pueden ver

  static bool canCreateFarm(String role) => isManager(role);
  static bool canCreatePlot(String role) => isManager(role);
  static bool canCreateCrop(String role) => isFarmer(role);
  static bool canRegisterActivity(String role) => isFarmer(role);
  static bool canManageSensors(String role) => isManager(role);
  static bool canInviteUsers(String role) => isAdmin(role);
  static bool canManageCosts(String role) => isManager(role);
}
