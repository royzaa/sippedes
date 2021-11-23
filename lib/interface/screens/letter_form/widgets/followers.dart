import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './text_input_field.dart';
import '../../../../services/firestore_services.dart';
import '../../../../model/follower.dart';

class Followers extends StatefulWidget {
  const Followers({Key? key, required this.nik}) : super(key: key);
  final int nik;

  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  final _noKK = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  bool validate() {
    bool status = false;
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();
      status = true;
    } else {
      status = false;
    }
    return status;
  }

  final List<Follower> followerAdded = [];

  void toggleFollower(Follower follower) {
    bool hasAdded = followerAdded.any((data) => data.name == follower.name);
    if (!hasAdded) {
      followerAdded.add(follower);
      setState(() {});
    } else if (hasAdded) {
      followerAdded.remove(follower);
      setState(() {});
    }
  }

  bool _isLoading = false;

  int? _kk;
  late List<Follower> _followersData;

  @override
  void initState() {
    _isLoading = true;
    FirestoreServices.getKK(widget.nik).then((value) {
      setState(() {
        _kk = value;
        debugPrint('nokk: $_kk');
      });

      if (_kk != null) {
        FirestoreServices.searchFamily(_kk!).then((value) {
          setState(() {
            _followersData = value;
            debugPrint('followers data: $_followersData');
            _isLoading = false;
          });
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _noKK.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {},
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Cari keluargamu",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Text(
                  'Isi no KK, kami carikan kerabatmu \nyang akan ikut berpindah',
                  style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 25.h,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Form(
                        key: _formKey,
                        child: TextInputField(
                          color: Theme.of(context).primaryColor,
                          controller: _noKK,
                          suffixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).primaryColor,
                          ),
                          inputType: TextInputType.phone,
                          fieldName: 'Input nomor kk',
                          customValidator: (value) {
                            RegExp regExp = RegExp(r'^[1-9]+[0-9]*$');
                            if (value == '' || value!.isEmpty) {
                              return 'Nomor _kk tidak boleh kosong';
                            } else if (!regExp.hasMatch(value)) {
                              return 'Nomor _kk hanya berupa angka';
                            } else if (!(value.length == 16)) {
                              return 'Nomor _kk berjumlah 16 digit';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          primary: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          shadowColor:
                              Theme.of(context).primaryColor.withOpacity(0.25),
                          elevation: 20,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                _isLoading = true;
                                await FirestoreServices.searchFamily(
                                        int.parse(_noKK.text))
                                    .then((value) {
                                  _followersData = value;
                                  _isLoading = false;
                                  setState(() {});
                                });
                              },
                        child: SizedBox(
                          width: size.width * 0.5,
                          height: 28.h,
                          child: _isLoading
                              ? Center(
                                  child: SizedBox(
                                    width: 28.w,
                                    child: const CircularProgressIndicator(
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Cari',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  'Atau tambah dari keluarga sendiri',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                _isLoading
                    ? SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _followersData.length,
                        itemBuilder: (context, index) {
                          Follower currentFollower = _followersData[index];
                          return _followersData.isNotEmpty
                              ? int.parse(currentFollower.noKTP) != widget.nik
                                  ? ListTile(
                                      title: Text(
                                        _followersData[index].name,
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                      trailing: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.r),
                                          ),
                                          primary:
                                              Theme.of(context).primaryColor,
                                        ),
                                        onPressed: () =>
                                            toggleFollower(currentFollower),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Icon(
                                              !followerAdded
                                                      .contains(currentFollower)
                                                  ? Icons.add
                                                  : Icons.remove,
                                              size: 18.r,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              !followerAdded
                                                      .contains(currentFollower)
                                                  ? 'Tambah'
                                                  : 'Kurangi',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox()
                              : const Center(
                                  child: Text('Keluarga tidak ditemukan'),
                                );
                        },
                      ),
                SizedBox(
                  height: 15.h,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    primary: Theme.of(context).primaryColor,
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                    shadowColor:
                        Theme.of(context).primaryColor.withOpacity(0.25),
                    elevation: 20,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(followerAdded);
                  },
                  child: Text(
                    'Lanjut',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
