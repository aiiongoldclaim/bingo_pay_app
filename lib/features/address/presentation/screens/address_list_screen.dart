import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';
import 'add_edit_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().loadUserAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Addresses")),

      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AddressListLoaded) {
            final addresses = state.addresses;

            if (addresses.isEmpty) {
              return const Center(child: Text("No addresses found"));
            }

            return ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (_, index) {
                final address = addresses[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(address.fullName),
                    subtitle: Text(
                      "${address.addressLine1}, ${address.city}, ${address.state}",
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// ✏️ Edit
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<AddressCubit>(),
                                  child: AddEditAddressScreen(
                                    existingAddress: address,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        /// 🗑 Delete
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context.read<AddressCubit>().removeAddress(
                              address.id,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is AddressError) {
            return Center(child: Text(state.errorMessage));
          }

          return const SizedBox();
        },
      ),

      /// ➕ Add New Address
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AddressCubit>(),
                child: const AddEditAddressScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
