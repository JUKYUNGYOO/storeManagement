// String selectedProductId;
// String selectedProductName;

// void handleDataRowClick(DataRow row) {
//   // 2단계: 선택한 행의 productId와 productName을 저장합니다.
//   selectedProductId = row.cells[0].value;  // cell[0]은 id라고 가정합니다.
//   selectedProductName = row.cells[1].value; // cell[1]은 name이라고 가정합니다.
// }

// void handleProductChange() async {
//   // 3단계: 상품 변경 버튼 클릭 처리
//   productId = selectedProductId;
//   productName = selectedProductName;

//   // 5단계: 변경된 데이터를 서버에 저장
//   final response = await http.patch(
//     Uri.parse('https://storepop.io/api/v2/worker/pog/query'),
//     body: json.encode({
//       "store_id": "6386f8694110633059830320",
//       "shelf_id": 1,
//       "row": 1, // 현재 선택된 행 값을 사용해야 합니다.
//       "column": 1 // 현재 선택된 열 값을 사용해야 합니다.
//     }),
//     headers: {
//       "Content-Type": "application/json",
//       "Authorization": "Bearer ${Provider.of<tokenModel>(context, listen: false).accessToken}",
//     },
//   );

//   if (response.statusCode == 200) {
//     // 데이터가 성공적으로 업데이트되었는지 확인 후 필요한 작업 수행
//   } else {
//     logger.d('HTTP PATCH 요청 실패: ${response.statusCode}');
//   }
// }

// // ... 나머지 코드 ...
 
  // "id" : "imstore01",
  // "pw" : "@tksoaowkd"
