/// The brand-level section selected in the dashboard's top app bar.
enum VaultSection {
  theVaults,
  vaultsLuxe,
  ultraLuxe;

  String get label {
    switch (this) {
      case VaultSection.theVaults:
        return 'TheVaults';
      case VaultSection.vaultsLuxe:
        return 'Vaults Luxe';
      case VaultSection.ultraLuxe:
        return 'Ultra Luxe';
    }
  }
}
