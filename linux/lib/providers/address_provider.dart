import 'package:flutter/material.dart';
import '../models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final List<Address> _addresses = [
    Address(
      id: "1",
      title: "Ev",
      city: "İstanbul",
      district: "Beşiktaş",
      fullAddress: "Mimoza Sok. No:5 D:2",
    ),
  ];

  List<Address> get addresses => _addresses;

  void addAddress(Address address) {
    _addresses.add(address);
    notifyListeners();
  }

  void updateAddress(String id, Address newAddress) {
    int index = _addresses.indexWhere((a) => a.id == id);
    if (index != -1) {
      _addresses[index] = newAddress;
      notifyListeners();
    }
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
