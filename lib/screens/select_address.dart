import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/city_response.dart';
import 'package:active_ecommerce_flutter/data_model/country_response.dart';
import 'package:active_ecommerce_flutter/data_model/state_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/address_repository.dart';
import 'package:active_ecommerce_flutter/screens/address.dart';
import 'package:active_ecommerce_flutter/screens/map_location.dart';
import 'package:active_ecommerce_flutter/screens/shipping_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:toast/toast.dart';

class SelectAddress extends StatefulWidget {
  int? owner_id;
  SelectAddress({Key? key, this.owner_id}) : super(key: key);

  @override
  State<SelectAddress> createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  ScrollController _mainScrollController = ScrollController();

  // integer type variables
  int? _seleted_shipping_address = 0;

  // list type variables
  List<dynamic> _shippingAddressList = [];
  List<dynamic> _selectedAddressList = [];

  // List<PickupPoint> _pickupList = [];
  // List<City> _cityList = [];
  // List<Country> _countryList = [];

  // String _shipping_cost_string = ". . .";

  // Boolean variables
  bool isVisible = true;
  bool _faceData = false;

  //double variables
  double mWidth = 0;

  int? _default_shipping_address = 0;
  City? _selected_city;
  Country? _selected_country;
  MyState? _selected_state;

  bool _isInitial = true;

  String? postal_code;

  //controllers for add purpose
  TextEditingController _addressController = TextEditingController();
  TextEditingController _postalCodeController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _countryController = TextEditingController();

  //for update purpose
  List<TextEditingController> _addressControllerListForUpdate = [];
  List<TextEditingController> _postalCodeControllerListForUpdate = [];
  List<TextEditingController> _phoneControllerListForUpdate = [];
  List<TextEditingController> _cityControllerListForUpdate = [];
  List<TextEditingController> _stateControllerListForUpdate = [];
  List<TextEditingController> _countryControllerListForUpdate = [];
  List<City?> _selected_city_list_for_update = [];
  List<MyState?> _selected_state_list_for_update = [];
  List<Country> _selected_country_list_for_update = [];

  double mHeight = 0;

  fetchAll() {
    if (is_logged_in.$ == true) {
      fetchShippingAddressList();
      //fetchPickupPoints();
    }
    setState(() {});
  }

  fetchShippingAddressList() async {
    _shippingAddressList.clear();
    var addressResponse = await AddressRepository().getAddressList();
    _shippingAddressList.addAll(addressResponse.addresses);
    if (_shippingAddressList.length > 0) {
      _seleted_shipping_address = _shippingAddressList[0].id;

      _shippingAddressList.forEach((address) {
        if (address.set_default == 1) {
          _seleted_shipping_address = address.id;
        }

        _addressControllerListForUpdate
            .add(TextEditingController(text: address.address));
        _postalCodeControllerListForUpdate
            .add(TextEditingController(text: address.postal_code));
        _phoneControllerListForUpdate
            .add(TextEditingController(text: address.phone));
        _countryControllerListForUpdate
            .add(TextEditingController(text: address.country_name));
        _stateControllerListForUpdate
            .add(TextEditingController(text: address.state_name));
        _cityControllerListForUpdate
            .add(TextEditingController(text: address.city_name));
        _selected_country_list_for_update
            .add(Country(id: address.country_id, name: address.country_name));
        _selected_state_list_for_update
            .add(MyState(id: address.state_id, name: address.state_name));
        _selected_city_list_for_update
            .add(City(id: address.city_id, name: address.city_name));
      });
    }
    print(_shippingAddressList);
    _faceData = true;
    setState(() {});

    // getSetShippingCost();
  }

  reset() {
    _shippingAddressList.clear();
    _faceData = false;
    _seleted_shipping_address = 0;
    _default_shipping_address = 0;
    _shippingAddressList.clear();
    _isInitial = true;

    _addressController.clear();
    _postalCodeController.clear();
    _phoneController.clear();

    _countryController.clear();
    _stateController.clear();
    _cityController.clear();

    //update-ables
    _addressControllerListForUpdate.clear();
    _postalCodeControllerListForUpdate.clear();
    _phoneControllerListForUpdate.clear();
    _countryControllerListForUpdate.clear();
    _stateControllerListForUpdate.clear();
    _cityControllerListForUpdate.clear();
    _selected_city_list_for_update.clear();
    _selected_state_list_for_update.clear();
    _selected_country_list_for_update.clear();
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  afterAddingAnAddress() {
    reset();
    fetchAll();
  }

  afterDeletingAnAddress() {
    reset();
    fetchAll();
  }

  afterUpdatingAnAddress() {
    reset();
    fetchAll();
  }

  onPressProceed(context) async {
    if (_seleted_shipping_address == 0) {
      ToastComponent.showSnackBar(
        context,
        LangText(context).local.choose_an_address_or_pickup_point,
      );
      return;
    }

    late var addressUpdateInCartResponse;

    if (_seleted_shipping_address != 0) {
      print(_seleted_shipping_address.toString() + "dddd");
      addressUpdateInCartResponse = await AddressRepository()
          .getAddressUpdateInCartResponse(
              address_id: _seleted_shipping_address);
      if (addressUpdateInCartResponse.result == false) {
        ToastComponent.showSnackBar(
          context,
          addressUpdateInCartResponse.message,
        );
        return;
      }
      print("Address id: $_seleted_shipping_address");
      _shippingAddressList.forEach((i) {
        if (i.id == _seleted_shipping_address) {
          if (i.address == null || i.address == '') {
            ToastComponent.showSnackBar(
              context,
              'Your address is not complete',
            );
            return;
          } else if (i.country_name == null || i.country_name == "") {
            ToastComponent.showSnackBar(
              context,
              'Your countryname is not complete',
            );
            return;
          } else if (i.state_name == null || i.state_name == "") {
            ToastComponent.showSnackBar(
              context,
              'Your state name is not complete',
            );

            return;
          } else if (i.city_name == null || i.city_name == "") {
            ToastComponent.showSnackBar(
              context,
              'Your city name is not complete',
            );
            return;
          } else if (i.phone == null || i.phone == '') {
            ToastComponent.showSnackBar(
              context,
              'Your phone no is not complete',
            );
            return;
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ShippingInfo(_seleted_shipping_address!);
            })).then((value) {
              onPopped(value);
            });
          }
        }
      });
    }
  }

  onAddressSwitch(index) async {
    var addressMakeDefaultResponse =
        await AddressRepository().getAddressMakeDefaultResponse(index);

    if (addressMakeDefaultResponse.result == false) {
      ToastComponent.showSnackBar(
        context,
        addressMakeDefaultResponse.message,
      );
      return;
    }

    ToastComponent.showSnackBar(
      context,
      addressMakeDefaultResponse.message,
    );

    setState(() {
      _default_shipping_address = index;
    });
  }

  onPressDelete(id) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.only(
                  top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
              content: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context)!
                      .are_you_sure_to_remove_this_address,
                  maxLines: 3,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
                ),
              ),
              actions: [
                Btn.basic(
                  child: Text(
                    AppLocalizations.of(context)!.cancel_ucf,
                    style: TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                Btn.basic(
                  color: MyTheme.soft_accent_color,
                  child: Text(
                    AppLocalizations.of(context)!.confirm_ucf,
                    style: TextStyle(color: MyTheme.dark_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    confirmDelete(id);
                  },
                ),
              ],
            ));
  }

  confirmDelete(id) async {
    var addressDeleteResponse =
        await AddressRepository().getAddressDeleteResponse(id);

    if (addressDeleteResponse.result == false) {
      ToastComponent.showSnackBar(
        context,
        addressDeleteResponse.message,
      );
      return;
    }

    ToastComponent.showSnackBar(
      context,
      addressDeleteResponse.message,
    );

    afterDeletingAnAddress();
  }

  onAddressAdd(context) async {
    var address = _addressController.text.toString();
    postal_code = _postalCodeController.text.toString();
    var phone = _phoneController.text.toString();

    if (address == "") {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.enter_address_ucf,
      );
      return;
    }

    if (_selected_country == null) {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.select_a_country,
      );
      return;
    }

    if (_selected_state == null) {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.select_a_state,
      );
      return;
    }

    if (_selected_city == null) {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.select_a_city,
      );
      return;
    }

    if (_phoneController.text.toString().isEmpty) {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.enter_phone_number,
      );
      return;
    }

    var addressAddResponse = await AddressRepository().getAddressAddResponse(
        address: address,
        country_id: _selected_country!.id,
        state_id: _selected_state!.id,
        city_id: _selected_city!.id,
        postal_code: postal_code!,
        phone: phone);

    if (addressAddResponse.result == false) {
      ToastComponent.showSnackBar(
        context,
        addressAddResponse.message,
      );
      return;
    }

    ToastComponent.showSnackBar(
      context,
      addressAddResponse.message,
    );

    Navigator.of(context, rootNavigator: true).pop();
    afterAddingAnAddress();
  }

  onAddressUpdate(context, index, id) async {
    var address = _addressControllerListForUpdate[index].text.toString();
    postal_code = _postalCodeControllerListForUpdate[index].text.toString();
    var phone = _phoneControllerListForUpdate[index].text.toString();

    if (address == "") {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.enter_address_ucf,
      );
      return;
    }

    if (_selected_country_list_for_update[index] == null) {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.select_a_country,
      );
      return;
    }

    if (_selected_state_list_for_update[index] == null) {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.select_a_state,
      );
      return;
    }

    if (_selected_city_list_for_update[index] == null) {
      ToastComponent.showSnackBar(
        context,
        AppLocalizations.of(context)!.select_a_city,
      );
      return;
    }

    var addressUpdateResponse = await AddressRepository()
        .getAddressUpdateResponse(
            id: id,
            address: address,
            country_id: _selected_country_list_for_update[index].id,
            state_id: _selected_state_list_for_update[index]!.id,
            city_id: _selected_city_list_for_update[index]!.id,
            postal_code: postal_code!,
            phone: phone);

    if (addressUpdateResponse.result == false) {
      ToastComponent.showSnackBar(
        context,
        addressUpdateResponse.message,
      );
      return;
    }

    ToastComponent.showSnackBar(
      context,
      addressUpdateResponse.message,
    );

    Navigator.of(context, rootNavigator: true).pop();
    afterUpdatingAnAddress();
  }

  onSelectCountryDuringAdd(country, setModalState) {
    if (_selected_country != null && country.id == _selected_country!.id) {
      setModalState(() {
        _countryController.text = country.name;
      });
      return;
    }
    _selected_country = country;
    _selected_state = null;
    _selected_city = null;
    setState(() {});

    setModalState(() {
      _countryController.text = country.name;
      _stateController.text = "";
      _cityController.text = "";
    });
  }

  onSelectStateDuringAdd(state, setModalState) {
    if (_selected_state != null && state.id == _selected_state!.id) {
      setModalState(() {
        _stateController.text = state.name;
      });
      return;
    }
    _selected_state = state;
    _selected_city = null;
    setState(() {});
    setModalState(() {
      _stateController.text = state.name;
      _cityController.text = "";
    });
  }

  onSelectCityDuringAdd(city, setModalState) async {
    print("PostalResponse: ${city.id}");
    var postalResponse =
        await AddressRepository().getPostalCodeByCidty(city.id);
    print("PostalResponse aa: ${postalResponse.success}");
    setState(() {
      postal_code = postalResponse.data.toString();
      _postalCodeController.text = postal_code!;
    });
    if (_selected_city != null && city.id == _selected_city!.id) {
      setModalState(() {
        _cityController.text = city.name;
      });
      return;
    }
    _selected_city = city;
    setModalState(() {
      _cityController.text = city.name;
    });
  }

  onSelectCountryDuringUpdate(index, country, setModalState) {
    if (country.id == _selected_country_list_for_update[index].id) {
      setModalState(() {
        _countryControllerListForUpdate[index].text = country.name;
      });
      return;
    }
    _selected_country_list_for_update[index] = country;
    _selected_state_list_for_update[index] = null;
    _selected_city_list_for_update[index] = null;
    setState(() {});

    setModalState(() {
      _countryControllerListForUpdate[index].text = country.name;
      _stateControllerListForUpdate[index].text = "";
      _cityControllerListForUpdate[index].text = "";
    });
  }

  onSelectStateDuringUpdate(index, state, setModalState) {
    if (_selected_state_list_for_update[index] != null &&
        state.id == _selected_state_list_for_update[index]!.id) {
      setModalState(() {
        _stateControllerListForUpdate[index].text = state.name;
      });
      return;
    }
    _selected_state_list_for_update[index] = state;
    _selected_city_list_for_update[index] = null;
    setState(() {});
    setModalState(() {
      _stateControllerListForUpdate[index].text = state.name;
      _cityControllerListForUpdate[index].text = "";
    });
  }

  onSelectCityDuringUpdate(index, city, setModalState) {
    if (_selected_city_list_for_update[index] != null &&
        city.id == _selected_city_list_for_update[index]!.id) {
      setModalState(() {
        _cityControllerListForUpdate[index].text = city.name;
      });
      return;
    }
    _selected_city_list_for_update[index] = city;
    setModalState(() {
      _cityControllerListForUpdate[index].text = city.name;
    });
  }

  _tabOption(int index, listIndex) {
    switch (index) {
      case 0:
        buildShowUpdateFormDialog(context, listIndex);
        break;
      case 1:
        onPressDelete(_shippingAddressList[listIndex].id);
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MapLocation(address: _shippingAddressList[listIndex]);
        })).then((value) {
          onPopped(value);
        });
        //deleteProduct(productId);
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    mHeight = MediaQuery.of(context).size.height;
    mWidth = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: UsefulElements.backButton(context),
          backgroundColor: Colors.white,
          title: buildAppbarTitle(context),
        ),
        backgroundColor: Colors.white,
        bottomNavigationBar: buildBottomAppBar(context),
        body: buildBody(context),
      ),
    );
  }

  RefreshIndicator buildBody(BuildContext context) {
    return RefreshIndicator(
      color: MyTheme.accent_color,
      backgroundColor: Colors.white,
      onRefresh: _onRefresh,
      displacement: 0,
      child: Container(
        child: buildBodyChildren(context),
      ),
    );
  }

  Widget buildBodyChildren(BuildContext context) {
    return buildShippingListContainer(context);
  }

  Container buildShippingListContainer(BuildContext context) {
    return Container(
      child: CustomScrollView(
        controller: _mainScrollController,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            // buildAddOrEditAddress(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    buildShowAddFormDialog(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 20, top: 20),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: MyTheme.accent_color),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          size: 24,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text("Add")
                      ],
                    ),
                  ),
                )
              ],
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildShippingInfoList()),
            SizedBox(
              height: 100,
            )
          ]))
        ],
      ),
    );
  }

  Widget buildAddOrEditAddress(BuildContext context) {
    return Container(
      height: 40,
      child: Center(
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Address(
                from_shipping_info: true,
              );
            })).then((value) {
              onPopped(value);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              LangText(context)
                  .local
                  .to_add_or_edit_addresses_go_to_address_page,
              style: TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  color: MyTheme.accent_color),
            ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        "${LangText(context).local.shipping_cost_ucf}",
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildShippingInfoList() {
    if (is_logged_in.$ == false) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            LangText(context).local.you_need_to_log_in,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else if (!_faceData && _shippingAddressList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_shippingAddressList.length > 0) {
      return SingleChildScrollView(
        child: ListView.builder(
          itemCount: _shippingAddressList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: buildShippingInfoItemCard(index),
            );
          },
        ),
      );
    } else if (_faceData && _shippingAddressList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            LangText(context).local.no_address_is_added,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  GestureDetector buildShippingInfoItemCard(index) {
    return GestureDetector(
      onTap: () {
        if (_seleted_shipping_address != _shippingAddressList[index].id) {
          _seleted_shipping_address = _shippingAddressList[index].id;

          // onAddressSwitch();
        }
        //detectShippingOption();
        setState(() {});
      },
      child: Column(
        children: [
          _seleted_shipping_address == _shippingAddressList[index].id
              ? Container(
                  padding: EdgeInsets.all(0),
                  child: Text(
                    "Set as your default address*",
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
              : Container(),
          Card(
            color: _seleted_shipping_address == _shippingAddressList[index].id
                ? Colors.grey.shade300
                : Colors.white,
            shape: RoundedRectangleBorder(
              // side: _seleted_shipping_address == _shippingAddressList[index].id
              //     ? BorderSide(color: MyTheme.accent_color, width: 2.0)
              //     : BorderSide(color: MyTheme.light_grey, width: 1.0),
              side: BorderSide(color: MyTheme.light_grey, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 0.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildShippingInfoItemChildren(index),
            ),
          )
        ],
      ),
    );
  }

  Column buildShippingInfoItemChildren(index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildShippingInfoItemAddress(index),
        buildShippingInfoItemCity(index),
        buildShippingInfoItemState(index),
        buildShippingInfoItemCountry(index),
        buildShippingInfoItemPostalCode(index),
        buildShippingInfoItemPhone(index),
      ],
    );
  }

  Padding buildShippingInfoItemPhone(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local.phone_ucf,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 180,
            child: Text(
              _shippingAddressList[index].phone,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
          Spacer(),
          buildShippingOptionsCheckContainer(
              _seleted_shipping_address == _shippingAddressList[index].id)
        ],
      ),
    );
  }

  Padding buildShippingInfoItemPostalCode(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local.postal_code,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 200,
            child: Text(
              _shippingAddressList[index].postal_code,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildShippingInfoItemCountry(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local.country_ucf,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 200,
            child: Text(
              _shippingAddressList[index].country_name,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildShippingInfoItemState(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local.state_ucf,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 200,
            child: Text(
              _shippingAddressList[index].state_name,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildShippingInfoItemCity(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local.city_ucf,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 200,
            child: Text(
              _shippingAddressList[index].city_name,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildShippingInfoItemAddress(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            child: Text(
              LangText(context).local.address_ucf,
              style: TextStyle(
                color: MyTheme.grey_153,
              ),
            ),
          ),
          Container(
            width: 150,
            child: Text(
              _shippingAddressList[index].address ?? '',
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
            ),
          ),
          Spacer(),
          showOptions(listIndex: index)
        ],
      ),
    );
  }

  Container buildShippingOptionsCheckContainer(bool check) {
    return check
        ? Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0), color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(Icons.check, color: Colors.white, size: 10),
            ),
          )
        : Container();
  }

  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: Container(
        color: Colors.transparent,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Btn.minWidthFixHeight(
              minWidth: MediaQuery.of(context).size.width,
              height: 50,
              color: MyTheme.accent_color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Text(
                LangText(context).local.continue_to_delivery_info_ucf,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                onPressProceed(context);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget customAppBar(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: MyTheme.white,
              child: Row(
                children: [
                  buildAppbarBackArrow(),
                ],
              ),
            ),
            // container for gaping into title text and title-bottom buttons
            Container(
              padding: EdgeInsets.only(top: 2),
              width: mWidth,
              color: MyTheme.light_grey,
              height: 1,
            ),
            //buildChooseShippingOption(context)
          ],
        ),
      ),
    );
  }

  Container buildAppbarTitle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      child: Text(
        "${LangText(context).local.shipping_info}",
        style: TextStyle(
          fontSize: 16,
          color: MyTheme.dark_font_grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Container buildAppbarBackArrow() {
    return Container(
      width: 40,
      child: UsefulElements.backButton(context),
    );
  }

  Future buildShowAddFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setModalState /*You can rename this!*/) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              contentPadding: EdgeInsets.only(
                  top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            "${AppLocalizations.of(context)!.address_ucf} *",
                            style: TextStyle(
                                color: MyTheme.dark_font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 55,
                          child: TextField(
                            controller: _addressController,
                            autofocus: false,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: buildAddressInputDecoration(
                                context,
                                AppLocalizations.of(context)!
                                    .enter_address_ucf),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            "${AppLocalizations.of(context)!.country_ucf} *",
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            suggestionsCallback: (name) async {
                              var countryResponse = await AddressRepository()
                                  .getCountryList(name: name);
                              return countryResponse.countries;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .loading_countries_ucf,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic country) {
                              //print(suggestion.toString());
                              return ListTile(
                                dense: true,
                                title: Text(
                                  country.name,
                                  style: TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            noItemsFoundBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .no_country_available,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            onSuggestionSelected: (dynamic country) {
                              onSelectCountryDuringAdd(country, setModalState);
                            },
                            textFieldConfiguration: TextFieldConfiguration(
                              onTap: () {},
                              //autofocus: true,
                              controller: _countryController,
                              onSubmitted: (txt) {
                                // keep this blank
                              },
                              decoration: buildAddressInputDecoration(
                                  context,
                                  AppLocalizations.of(context)!
                                      .enter_country_ucf),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            "${AppLocalizations.of(context)!.state_ucf} *",
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            suggestionsCallback: (name) async {
                              if (_selected_country == null) {
                                var stateResponse = await AddressRepository()
                                    .getStateListByCountry();
                                return stateResponse.states;
                              }
                              var stateResponse = await AddressRepository()
                                  .getStateListByCountry(
                                      country_id: _selected_country!.id,
                                      name: name);
                              return stateResponse.states;
                              // var stateResponse = await AddressRepository()
                              //     .getStateListByCountry();
                              // return stateResponse.states;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .loading_states_ucf,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic state) {
                              //print(suggestion.toString());
                              return ListTile(
                                dense: true,
                                title: Text(
                                  state.name,
                                  style: TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            noItemsFoundBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .no_state_available,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            onSuggestionSelected: (dynamic state) {
                              onSelectStateDuringAdd(state, setModalState);
                            },
                            textFieldConfiguration: TextFieldConfiguration(
                              onTap: () {},
                              //autofocus: true,
                              controller: _stateController,
                              onSubmitted: (txt) {
                                // _searchKey = txt;
                                // setState(() {});
                                // _onSearchSubmit();
                              },
                              decoration: buildAddressInputDecoration(
                                  context,
                                  AppLocalizations.of(context)!
                                      .enter_state_ucf),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            "${AppLocalizations.of(context)!.city_ucf} *",
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            suggestionsCallback: (name) async {
                              if (_selected_state == null) {
                                var cityResponse = await AddressRepository()
                                    .getCityListByState(); // blank response
                                return cityResponse.cities;
                              }
                              var cityResponse = await AddressRepository()
                                  .getCityListByState(
                                      state_id: _selected_state!.id,
                                      name: name);
                              return cityResponse.cities;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .loading_cities_ucf,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic city) {
                              //print(suggestion.toString());
                              return ListTile(
                                dense: true,
                                title: Text(
                                  city.name,
                                  style: TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            noItemsFoundBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .no_city_available,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            onSuggestionSelected: (dynamic city) {
                              onSelectCityDuringAdd(city, setModalState);
                            },
                            textFieldConfiguration: TextFieldConfiguration(
                              onTap: () {},
                              //autofocus: true,
                              controller: _cityController,
                              onSubmitted: (txt) {
                                // keep blank
                              },
                              decoration: buildAddressInputDecoration(context,
                                  AppLocalizations.of(context)!.enter_city_ucf),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(AppLocalizations.of(context)!.postal_code,
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _postalCodeController,
                            autofocus: false,
                            enabled: false,
                            decoration: buildAddressInputDecoration(
                                context,
                                AppLocalizations.of(context)!
                                    .enter_postal_code_ucf),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(AppLocalizations.of(context)!.phone_ucf,
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _phoneController,
                            autofocus: false,
                            decoration: buildAddressInputDecoration(
                                context,
                                AppLocalizations.of(context)!
                                    .enter_phone_number),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            side: BorderSide(
                                color: MyTheme.light_grey, width: 1)),
                        child: Text(
                          LangText(context).local.close_ucf,
                          style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 28.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: MyTheme.accent_color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          LangText(context).local.add_ucf,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          onAddressAdd(context);
                        },
                      ),
                    )
                  ],
                )
              ],
            );
          });
        });
  }

  InputDecoration buildAddressInputDecoration(BuildContext context, hintText) {
    return InputDecoration(
        filled: true,
        fillColor: MyTheme.light_grey,
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 12.0, color: MyTheme.textfield_grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.noColor, width: 0.5),
          borderRadius: const BorderRadius.all(
            const Radius.circular(8.0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyTheme.noColor, width: 1.0),
          borderRadius: const BorderRadius.all(
            const Radius.circular(8.0),
          ),
        ),
        contentPadding: EdgeInsets.only(left: 8.0, top: 16.0, bottom: 16.0));
  }

  Future buildShowUpdateFormDialog(BuildContext context, index) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setModalState /*You can rename this!*/) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              contentPadding: EdgeInsets.only(
                  top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            "${AppLocalizations.of(context)!.address_ucf} *",
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 55,
                          child: TextField(
                            controller: _addressControllerListForUpdate[index],
                            autofocus: false,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: buildAddressInputDecoration(
                                context,
                                AppLocalizations.of(context)!
                                    .enter_address_ucf),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            "${AppLocalizations.of(context)!.country_ucf} *",
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            suggestionsCallback: (name) async {
                              var countryResponse = await AddressRepository()
                                  .getCountryList(name: name);
                              return countryResponse.countries;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .loading_countries_ucf,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic country) {
                              //print(suggestion.toString());
                              return ListTile(
                                dense: true,
                                title: Text(
                                  country.name,
                                  style: TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            noItemsFoundBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .no_country_available,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            onSuggestionSelected: (dynamic country) {
                              onSelectCountryDuringUpdate(
                                  index, country, setModalState);
                            },
                            textFieldConfiguration: TextFieldConfiguration(
                              onTap: () {},
                              //autofocus: true,
                              controller:
                                  _countryControllerListForUpdate[index],
                              onSubmitted: (txt) {
                                // keep this blank
                              },
                              decoration: buildAddressInputDecoration(
                                  context,
                                  AppLocalizations.of(context)!
                                      .enter_country_ucf),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            "${AppLocalizations.of(context)!.state_ucf} *",
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            suggestionsCallback: (name) async {
                              if (_selected_country_list_for_update[index] ==
                                  null) {
                                var stateResponse = await AddressRepository()
                                    .getStateListByCountry(); // blank response
                                return stateResponse.states;
                              }
                              var stateResponse = await AddressRepository()
                                  .getStateListByCountry(
                                      country_id:
                                          _selected_country_list_for_update[
                                                  index]
                                              .id,
                                      name: name);
                              return stateResponse.states;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .loading_states_ucf,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic state) {
                              //print(suggestion.toString());
                              return ListTile(
                                dense: true,
                                title: Text(
                                  state.name,
                                  style: TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            noItemsFoundBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .no_state_available,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            onSuggestionSelected: (dynamic state) {
                              onSelectStateDuringUpdate(
                                  index, state, setModalState);
                            },
                            textFieldConfiguration: TextFieldConfiguration(
                              onTap: () {},
                              //autofocus: true,
                              controller: _stateControllerListForUpdate[index],
                              onSubmitted: (txt) {
                                // _searchKey = txt;
                                // setState(() {});
                                // _onSearchSubmit();
                              },
                              decoration: buildAddressInputDecoration(
                                  context,
                                  AppLocalizations.of(context)!
                                      .enter_state_ucf),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            "${AppLocalizations.of(context)!.city_ucf} *",
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 40,
                          child: TypeAheadField(
                            suggestionsCallback: (name) async {
                              if (_selected_state_list_for_update[index] ==
                                  null) {
                                var cityResponse = await AddressRepository()
                                    .getCityListByState(); // blank response
                                return cityResponse.cities;
                              }
                              var cityResponse = await AddressRepository()
                                  .getCityListByState(
                                      state_id: _selected_state_list_for_update[
                                              index]!
                                          .id,
                                      name: name);
                              return cityResponse.cities;
                            },
                            loadingBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .loading_cities_ucf,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            itemBuilder: (context, dynamic city) {
                              //print(suggestion.toString());
                              return ListTile(
                                dense: true,
                                title: Text(
                                  city.name,
                                  style: TextStyle(color: MyTheme.font_grey),
                                ),
                              );
                            },
                            noItemsFoundBuilder: (context) {
                              return Container(
                                height: 50,
                                child: Center(
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .no_city_available,
                                        style: TextStyle(
                                            color: MyTheme.medium_grey))),
                              );
                            },
                            onSuggestionSelected: (dynamic city) {
                              onSelectCityDuringUpdate(
                                  index, city, setModalState);
                            },
                            textFieldConfiguration: TextFieldConfiguration(
                              onTap: () {},
                              //autofocus: true,
                              controller: _cityControllerListForUpdate[index],
                              onSubmitted: (txt) {
                                // keep blank
                              },
                              decoration: buildAddressInputDecoration(context,
                                  AppLocalizations.of(context)!.enter_city_ucf),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(AppLocalizations.of(context)!.postal_code,
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller:
                                _postalCodeControllerListForUpdate[index],
                            autofocus: false,
                            decoration: buildAddressInputDecoration(
                                context,
                                AppLocalizations.of(context)!
                                    .enter_postal_code_ucf),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(AppLocalizations.of(context)!.phone_ucf,
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: _phoneControllerListForUpdate[index],
                            autofocus: false,
                            decoration: buildAddressInputDecoration(
                                context,
                                AppLocalizations.of(context)!
                                    .enter_phone_number),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            side: BorderSide(
                                color: MyTheme.light_grey, width: 1.0)),
                        child: Text(
                          AppLocalizations.of(context)!.close_all_capital,
                          style: TextStyle(
                              color: MyTheme.accent_color, fontSize: 13),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 28.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 40,
                        color: MyTheme.accent_color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.update_all_capital,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          onAddressUpdate(
                              context, index, _shippingAddressList[index].id);
                        },
                      ),
                    )
                  ],
                )
              ],
            );
          });
        });
  }

  GestureDetector buildAddressItemCard(index) {
    return GestureDetector(
      onDoubleTap: () {
        if (_default_shipping_address != _shippingAddressList[index].id) {
          onAddressSwitch(_shippingAddressList[index].id);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
            border: Border.all(
                color:
                    _default_shipping_address == _shippingAddressList[index].id
                        ? MyTheme.accent_color
                        : MyTheme.light_grey,
                width:
                    _default_shipping_address == _shippingAddressList[index].id
                        ? 1.0
                        : 0.0)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.address_ucf,
                            style: TextStyle(
                              color: MyTheme.grey_153,
                            ),
                          ),
                        ),
                        Container(
                          width: 175,
                          child: Text(
                            _shippingAddressList[index].address ?? "",
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.city_ucf,
                            style: TextStyle(
                              color: MyTheme.grey_153,
                            ),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].city_name,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.state_ucf,
                            style: TextStyle(
                              color: MyTheme.grey_153,
                            ),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].state_name,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.country_ucf,
                            style: TextStyle(
                              color: MyTheme.grey_153,
                            ),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].country_name,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.postal_code,
                            style: TextStyle(
                              color: MyTheme.grey_153,
                            ),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].postal_code,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 75,
                          child: Text(
                            AppLocalizations.of(context)!.phone_ucf,
                            style: TextStyle(
                              color: MyTheme.grey_153,
                            ),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            _shippingAddressList[index].phone,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.dark_grey,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            app_language_rtl.$!
                ? Positioned(
                    left: 0.0,
                    top: 10.0,
                    child: showOptions(listIndex: index),
                  )
                : Positioned(
                    right: 0.0,
                    top: 10.0,
                    child: showOptions(listIndex: index),
                  ),
          ],
        ),
      ),
    );
  }

  Widget showOptions({listIndex, productId}) {
    return Container(
      width: 45,
      child: PopupMenuButton<MenuOptions>(
        offset: Offset(-25, 0),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Container(
            width: 45,
            padding: EdgeInsets.only(right: 5),
            alignment: Alignment.topRight,
            child: Image.asset("assets/more.png",
                width: 4,
                height: 16,
                fit: BoxFit.contain,
                color: MyTheme.grey_153),
          ),
        ),
        onSelected: (MenuOptions result) {
          _tabOption(result.index, listIndex);
          // setState(() {
          //   //_menuOptionSelected = result;
          // });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Edit,
            child: Text(AppLocalizations.of(context)!.edit_ucf),
          ),
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Delete,
            child: Text(AppLocalizations.of(context)!.delete_ucf),
          ),
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.AddLocation,
            child: Text(AppLocalizations.of(context)!.add_location_ucf),
          ),
        ],
      ),
    );
  }

/*
  Widget buildChooseShippingOption(BuildContext context) {
    // if(carrier_base_shipping.$){
    if (true) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        width: DeviceInfo(context).width,
        alignment: Alignment.center,
        child: Text(
          "Choose Shipping Area",
          style: TextStyle(
              color: MyTheme.dark_grey,
              fontSize: 14,
              fontWeight: FontWeight.w700),
        ),
      );
    }
    return Visibility(
      visible: pick_up_status.$,
      child: ScrollToHideWidget(
        child: Container(
          color: MyTheme.white,
          //MyTheme.light_grey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildAddresOption(context),
              Container(
                width: 0.5,
                height: 30,
                color: MyTheme.grey_153,
              ),
              buildPockUpPointOption(context),
            ],
          ),
        ),
        scrollController: _mainScrollController,
        childHeight: 40,
      ),
    );
  }*/
/*
  FlatButton buildPockUpPointOption(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          changeShippingOption(false);
        });
      },
      child: Container(
        color: MyTheme.white,
        alignment: Alignment.center,
        height: 50,
        width: (mWidth / 2) - 1,
        child: Text(
          LangText(context).local.pickup_point,
          style: TextStyle(
              color: _shippingOptionIsAddress
                  ? MyTheme.medium_grey_50
                  : MyTheme.dark_grey,
              fontWeight: !_shippingOptionIsAddress
                  ? FontWeight.w700
                  : FontWeight.normal),
        ),
      ),
    );
  }


  FlatButton buildAddresOption(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          changeShippingOption(true);
        });
      },
      child: Container(
        color: MyTheme.white,
        height: 50,
        width: (mWidth / 2) - 1,
        alignment: Alignment.center,
        child: Text(
          LangText(context).local.address_screen_address,
          style: TextStyle(
              color: _shippingOptionIsAddress
                  ? MyTheme.dark_grey
                  : MyTheme.medium_grey_50,
              fontWeight: _shippingOptionIsAddress
                  ? FontWeight.w700
                  : FontWeight.normal),
        ),
      ),
    );
  }
  */
}

enum MenuOptions { Edit, Delete, AddLocation }
