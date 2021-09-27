class KtpModel {
  const KtpModel(
      {required this.dataKk,
      required this.dataPenduduk,
      required this.tanggalDibuat});
  final DataKepalaKeluarga dataKk;
  final DataPenduduk dataPenduduk;
  final String tanggalDibuat;
}

class DataKepalaKeluarga {
  const DataKepalaKeluarga(
      {required this.alamat,
      required this.namaKepalaKeluarga,
      required this.nomorKK});
  final String nomorKK, namaKepalaKeluarga, alamat;
}

class DataPenduduk {
  const DataPenduduk({
    required this.agama,
    required this.ayah,
    required this.goldar,
    required this.ibu,
    required this.jenisKelamin,
    required this.kewarganegaraan,
    required this.namaLengkap,
    required this.nik,
    required this.pekerjaan,
    required this.statusHubunganDalamRT,
    required this.statusKawin,
    required this.tanggalLahir,
    required this.tempatLahir,
  });
  final String nik,
      namaLengkap,
      jenisKelamin,
      statusHubunganDalamRT,
      tanggalLahir,
      tempatLahir,
      statusKawin,
      agama,
      goldar,
      kewarganegaraan,
      pekerjaan,
      ayah,
      ibu;
}
