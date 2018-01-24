Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") { |file| require file }
include RakeHelper

all_tokens = []
Document.where("tags LIKE '%aba%'").each do |d|
	all_tokens << d.data.file.public_id
end

xero_ids = ['a7507c9c-04a8-4836-87be-5d02a30592a7','4207431b-6616-45bc-a0f6-35a6037fb6cd','894c9590-fe55-4cfb-a565-e9ec4fbe671b','d38a4f6f-679d-4865-81d7-75c0b3192a3b','f32c87ca-d7cc-4573-90d7-2b42d7288a08','31ab6427-341b-42dc-ae16-f174ece41d5e','ee77af15-8132-4c5e-aea9-e45219783657','263b81f8-df43-41b8-9eea-102cb63c1581','44f18635-aad3-455a-92a5-5b6f553b3424','a9db59a2-df6f-42c2-a53a-5989084f6d2a','a2807575-0d89-4354-a1ed-35a0876016ca','351f1253-2ab2-4d68-b3a0-496da624a49c','55a2f8ae-9627-41da-8872-f7c2658e19a7','b279b4dd-45c3-4deb-904c-cc0615a3c9d8','b1482498-9b5b-4a89-b270-a9ade32d6cdd','aa93c36a-5172-47f4-984a-e9754d7e2426','6c925f6e-191f-4817-8705-a9dc6dff0fe2','121abe55-7a20-41e1-bc11-b911f857dfac','9648616d-7327-43b5-af52-31fce01004ce','5607c6d3-0fb3-45da-a28a-fdc4c76668ea','2c88d60b-781f-4915-b1d9-9ee62ff5a85c','4fdeee57-4594-4df8-9577-63e0ffd9086b','89154484-d32b-4de6-9251-908c81778d17','73f8d669-fab7-4f1a-a55f-2392c98190b4','8acd0f6c-7145-439f-868a-baaa62027c5f','2e6fd5d1-f6b6-4ea8-a690-7e296bccb46c','64976fd1-8c2c-45ed-8fc3-4038def78b13','e1b06841-611b-4c4f-aee4-677aadfb5f58','0db28e3a-4779-443a-a8a1-f3d8e51ee6e9','147541d8-f0db-42e2-bcc0-7757c8a564df','47039bac-838f-45a8-9a1a-4a8d12e4da38','2042b0dc-a8f1-437d-b994-fff10cc9905b','e31ad623-7faf-424f-abac-92c23679f69b','09ff2736-5f16-4945-9641-4fb6456d9867','e7bcbc06-f65d-488e-af18-bddb67917869','978c1418-29f0-4a1e-bb48-7e6eb451d9d5','4db88b5c-a72b-4e38-8268-40bdea305e0b','1da50060-9304-41a6-9802-db7cda912392','080597a6-3217-4f66-a0ab-bfc1cd880e0c','2f571d3b-6e3c-4ff2-ace5-3ebdf0f5f207','0dc06056-1602-4b60-9ade-af6ca245976a','61c3c89b-21a5-4c47-b4ae-5a9303937234','fbafd220-4626-4938-a54b-8da1eed7dcac','e4044215-f6e2-4d1e-8023-e08852eaa33b','aaad3b14-4194-4474-8c57-4e89821cd918','e282421b-1457-4b24-8e93-ff9685268806','0bfd5a61-37fb-4c39-9c1b-c555c6d38083','b83a12ac-6592-4be5-bb89-2e4d9d50b6e9','aa8c6587-7d36-42e5-a9d7-8d40cd41fac7','b249e9fe-3691-45c0-b473-ca8308711804','6f3497e0-3882-4ddf-b6b0-49a608f66dab','d5ea0800-f617-4339-bfc3-ed5f75865766','5d8b45e4-905c-445a-a8e9-f2449af7ebb3','cfc2b4ce-09c1-4e95-95b3-488b2443c785','c11d8aab-a7f5-40d0-b5c8-3e61dd39de85','2da569ff-b21f-4f24-8c1f-67ca2f86c187','a21a1acd-c627-4559-baa4-4742519d3c21','efbbf086-abda-46b1-9a08-95dfcad0f710','6f7bbe94-62a9-42d1-8e71-0914681fccaa','fc0cc8e5-ae5c-442d-905b-df9b901664dc','3e7f2506-5566-49b5-87e8-9cc1397893d6','e19833cb-47cb-4ee3-b5be-0040a91c56e5','24d721d9-8b6f-47c1-95a4-be10aa72b3a2','f481792c-4ac2-4642-bb2b-87b7ad262f80','bf7f2d7e-23c7-4214-944b-8d05ee436193','721e8abe-761a-4e09-befc-41c9295efa1d','018185f5-dfe8-48e9-983e-554b69e254b2','939b7695-9663-4e62-b4b8-bf5d3130c012','f26f21ee-0154-41a0-9b54-3d3f7322c362','3f682013-4fda-41cd-8466-cc31f106bbc0','6fbc5f56-1c1e-4eae-a367-a538063bcabd','0abed070-6b35-48c5-b029-b92526ff0cc5','f00eeffa-596b-47f0-8cb1-3bfb29111e0e','ccfa9a72-2077-4e4c-9e7a-77ba5e86d840','10cf8f65-ed27-403b-ad5c-08c3823fa454','5ffde8b8-d828-4291-9818-7c9a583b9e29','86394288-e814-4383-aebf-4bef7bada311','0fddb00f-58fb-4764-bc0c-02dd365e651f','45b1bc41-a86f-4cc7-b676-756729f1c67a','ae2a36cf-8ba6-4246-982e-08bdf22179bc','64b20ba6-177b-4ddb-814f-4d4692c088f2','777b2f13-73ae-41b3-97ed-9a81717b1b9a','e4346c69-f20b-4475-9ba1-c2fc8fe4bc36','3d53b3cd-47f7-48d5-8113-d0a364c5422a','b4f23e65-cec7-4c1c-89b0-0e0927e9331c','070c0dfc-2dd4-462a-a0d9-572f0ee7d7b6','10f872f9-b1c7-4b6d-b348-871ae1c57689','95ff1b2e-9ef2-4adb-9acd-6810252b917c','b5698db6-e020-4916-a8c1-7305d5c1ba16','eff25e91-d314-4fa2-a071-59141dc57fe3','091ed5b3-9bbc-443b-bba4-182231b7b885','35fae29e-9c9d-4670-a5c9-7c6c240f7673','0729d7ad-82df-4f61-9e64-033017008d93','916e4c63-691d-4a0a-951a-c17a7c521503','3aa1ceb5-e4ad-4cf3-8dab-f7f8579edfb7','11977d28-38c4-4a8b-8b69-e6b1d683a3d3','be57e0ad-3c52-4e22-892d-74e581a51d66','c6a3efd6-a8ca-4a8e-bb19-3b2a6def2ead','13272f80-2ab0-418a-b819-71bd87a3aaff','824c28ff-cd49-4dcf-a42e-66faaa2667c9','9f76ed3e-19f6-4ffb-8b84-a3d33e48023a','e991a561-2ed1-4e00-98d8-c524e80d8678','4b2ea5ce-f48b-4bff-9532-2cb050675652','58b8c845-32a4-488d-b2e9-39c61b8de020','59710b10-9a8b-487f-a387-34371dadeac1','c4e33cce-cbfc-423b-82c1-9f1096ff08f2','08589bea-a769-47ff-9bf0-b6f5628f68ca','46f05045-a354-4951-aa80-316927d35bc4','97741f0a-020b-49d1-ba95-9b8df2bb546a','10956032-13ab-4367-91dc-d58185a02b6d','4485235d-53ef-47c8-9fc0-234851f089ed','c7edf89e-6fe5-4417-9d12-59ceec19e81f','878fe0f4-c8c6-4f4d-b5c0-9f241f31add9','78db5179-1998-432d-9dce-5f4b8c25cb81','f4023238-e297-4843-bb4d-ff1e3d5b0d90','46a6d1a6-aecc-4aed-beb2-f0ae4d333e55','0ea5cab6-371e-4bac-8fc9-ad08bbf0b2c2','1607e083-56eb-4e19-abb2-a1a7bb919647','452b0120-fd04-4a61-a029-5d7ce6aa9426','cd9a7fd0-50f6-4bfb-a4fa-42071a525a2d','f488e6dd-2681-4cce-b402-baa1462cff5d','2fc33fc0-ae8e-4a15-9221-11399e5f2c27','47ef2b29-35f1-4c4f-9009-8b34dc0ea930','2fa7237d-cb47-4d33-9491-dba1d1f2f301','fd5b2b88-d0c5-4748-9be8-913005f6807d','63e056d7-d43c-4005-b4e4-84ce2fbe416b','4cf93d6c-8351-44fc-9257-36238aca0582','bfd72e4e-f900-4bfa-8943-d3eaa08e58ad','dad344c4-8345-4fe9-8ae0-77f5af7f8b96','b40d5fb7-a40b-4e2b-b5b9-69b2bacb06cf','f6f24e90-03e2-43f4-9eb7-a9dfa63103f5','a4e7866f-f3b2-4c16-babe-d3d43be9e125','acedbf93-1d61-44ae-91ee-560336bf864e','c163bc85-0402-4ad5-b184-5070755b4fe5','150e66a0-3a2f-49d2-b1df-81f5b5c6265d','ab42c22a-1a85-4bc0-b59e-c2be314c0310','692c8685-a98f-4746-be7c-8a504cb95840','9da89360-5daa-4f7b-af0d-80653446d6d8','a7eaf121-871a-4665-a0de-910e1b81c390','44a149a0-eca7-4809-affd-2cbcb0962233','faa63534-8326-419e-bb41-dd1256c5d7e6','257bc238-d4ac-484c-8514-421015fd23ed','ad63c977-47b0-404b-91f2-fba89b8f93ec','a79d6960-be84-4af7-a0c4-5f5a5d7791c9','03bcf346-788f-43ac-876d-00ffab6ecc64','a4c5519a-e4fd-4f00-81f1-4f80e4a3b4cd','564d0c79-7ad8-49f6-84d2-0d0197286d8f','622914a3-80f4-41fd-914e-c3d559b2ab6d','1d2c369f-5d7d-4c48-9884-de43ff978596','a70a93a8-e451-498f-8342-7c73262cfa77','48809f25-9ae3-4627-abfa-8600a71f465c','c793c5c3-1f90-4c94-8fb9-8190bbd8eb90','de51d2cd-62ff-4dcc-8764-3d4413841911','04f087cb-bfe3-4136-86cb-b34414b0bf05','2f6ec125-0a43-4842-ba56-94f1873f132a','5af576ae-6bf6-422f-a61b-713920f5e793','06c42f64-26d4-4061-a39e-f24acbcea92f','a1a688b8-290b-47ea-b3f5-7e29e3f22a68','bab2075c-1142-46c4-a7d7-3c4f334cea38','084def7f-1b95-46b1-b2f6-ca2933e0945d','da1c0954-715b-42ff-8cbc-81fd33a3dc43','e71bd3cf-6c28-449b-8841-827f2f97a9b6','0b7d6670-803c-4b47-932a-43a9c0c481e3','2b48eb86-b197-4ef6-90a5-18d8d96046ae','628e543f-f042-48f4-a374-03bde00ea47c','0b632ebc-935d-4eb4-9e9d-fe0be2a992a9','f8fa62cb-66e4-4c56-a67e-3bcd6b084e0c','5d922dff-11d1-4bb1-8cb3-cf9654f2ce51','519257f9-1ff8-4579-9d15-1c29c7adeb32','993fbf5f-678e-49e3-b56b-65e69d70c3e0','539d6417-fb4d-443a-be9c-e3623625a1e4','822c58c3-c863-4fb2-b1f0-c7247207a56b','24185f86-330a-4f48-81da-4d7035ca3350','a50679a0-7cac-4293-8e98-0e2f3593145f','c0ad3688-9468-4ad8-8b17-3baf14374698','3d64f8fd-fad6-4fd1-a538-0215ac052178','1d69ef66-33d6-4e09-8a87-cdf2b243ec80','46149abc-fe51-4e4b-b45d-517506322fd9','8f5244ab-7965-4990-b9b6-49f541c3f38f','836c69ad-8bb7-495b-9343-346dbae3ef4d','597a33d2-c7c8-429c-b93b-e6dc42fbbaec','bd8f0cfb-aa8b-48e2-98c0-42becfbcb378','0985cd91-d7b0-45d9-a5f6-f192bdeed85b','4df47b49-1f59-44fa-8a2d-e5281ff199c4','536179b6-8144-4699-b8f3-28c3ff04e154','17ea8307-2a0e-42ef-ad9a-88aa2b459ef5','97e97eac-b922-4b6e-b298-14f1e94eac74','4b7ec7a3-d081-4edc-92d6-508a2b7d29b2','1be21f09-0a1a-4199-9684-2cbd7e93993b','a49a41c1-80a7-4410-8c86-97da819b0a34','d303b444-e166-4c40-a620-54cfcd284dc2','46f69e1f-a5f7-4e25-b3f5-5ca748c640f2','c1e727c4-914b-4fcc-a042-13eb2c148635','248ef4d3-bb8c-4624-ae38-29e3151ed74b','cd107b33-77eb-401c-8a7d-90811c27e0ba','bdea1ff9-5982-400f-a972-4e44e74ae6f2','109fc97a-e10c-44d8-9453-238e265c823e','53b85360-e5d5-4618-a37f-cc0d2921f400','59ff015c-6edc-453a-8321-b261c1af3f9f','5f85c378-81e9-44e3-9ae4-77a53c3483be','5c339633-898c-405a-9e1d-607fae2c46f5','9dc0124c-bdcc-4aeb-8bcb-3d8c934963ac','ccb8a84d-15f0-4fe3-8f09-46d25e40ac27','756e82a2-bb03-4267-8d8b-93735dbe24a4','fcfb4861-191e-4788-a5a9-98762204ed79','09f0965b-d20b-4ae1-9960-e373a069781f','d2059daa-ea56-429d-a4de-db0453137d64','bdb47faa-04f7-4349-bf18-fd8831084f82','055a1254-d38c-4cb6-be8a-09ef4dea5174','96d5a4e0-0d1f-4020-9bef-057541314931','b522500c-8d23-48f8-88d3-5fb59988f631','6270fbf5-af70-4457-9f43-5f2d903922dc','1c98a2ca-8cfa-4927-8ba2-6c2baac65488','318e2f8a-863f-4d38-be27-c3fa66b8a28c','d05f81ed-227a-486d-ae6c-063daa22d0e4','e86b3a65-38da-4ccd-ab49-a6c43006b2b8','3a1241d0-05a5-4a4c-8e2c-de5f08aec480','dda7de6e-23f0-40a1-b770-feea594f2c7a','9b8477a3-66d8-4812-9f9d-96ba5c901ccd','45ce4de7-fa8a-4392-aa22-42b78f4bdcfe','1c100210-ef51-4b43-b2f5-054a1e7af4d4','dadad249-0d1a-47d5-9cf0-31f93f16d2a8','00c971c1-b678-4c03-9584-6d6cf97a69d4','f77f8060-8c82-4fd6-9f93-15aee1bbb003','eaee2a3f-2786-4957-9d00-02fd4fc586df','466ecc34-89bd-4add-aeb7-ff351805db15','4bc3d88c-8286-49e2-8374-c87ed9c0a9e1','6de8f534-27f7-4e63-8f55-31c4fa1a9c0e','5d86bdc7-b7ce-4859-a1ad-e4ccb40d8237','306a373c-d222-4a6e-b5f5-863ed8866448','4ba972ac-df81-4700-976d-bf53c21d66ea','443308e3-12e0-4cbc-bb54-781ada9ce50e','73a275c2-2c20-4770-98d0-d9ca313a8bc1','ecc19a9b-bf22-4922-8b94-12db1eeb0a0c','0c2580c3-ee20-4093-a1cd-e7448af57517','e0501bc2-f234-405e-80f6-546c96987661','96874585-0e27-45e1-a9f2-a58298dd0a57','4e41e2f0-42a0-4454-83a3-d5b30646c65d','08e56750-9f66-4cda-9376-73cd01ed22aa','40fe3ef4-33bf-484b-8720-8627997b7016','033b9c0a-89b3-4242-8917-66235181a007','769602a3-a67e-41bf-8351-4443c33df11c','72a3319f-4937-454d-9d4e-b0f09adea90e','f0d9f5a2-f595-487d-a733-dacc96489594','e45017bd-6034-4f69-b098-3364729ad9a3','f5ed686c-f015-4587-bce3-9922838aa6e1','869f0fe7-ba91-4cc8-ab81-c94ceb711eed','f9275cac-5076-4bda-a958-55cc4af86ed8','a2f7919c-d7a2-4636-afce-2b60142ea38f','5258f99d-170d-4796-95fa-8ae5fd65d04f','509818fd-7f57-407f-ba90-8b9d24802515','3a7125ea-0287-4b34-a6fc-101f611df2a1','bc3e1a0d-652d-4cee-bf30-28a58f5e3106','eee19013-01db-4ddd-bf36-a22ba6ad1b64','2ba89a0a-eb38-4c0a-a8c4-93d98553656f','faf5450f-f811-4cd1-bb66-5f1294ef5395','221d8c2f-ca47-4a4f-b9e1-6cc9dad3e81c','a962f656-4a75-4a1e-839f-24c414828b20','9196082f-d37d-4180-b274-559a1a265454','6b361cbd-fd5b-484b-925d-759c338f0648','88272a62-f38b-4b23-b0d8-6d0f3b1ebc98','df865e7a-f218-48d0-b5fa-e4d04ac40f8c','893fb2c2-00c5-4f72-8c7a-5dda0e953cd1','313806ce-ee77-4767-bcf2-b06d4e52dd67','39459206-ac9b-48b6-a653-f1e1b506c3a0','94552986-bdad-471b-b46d-09ffbd6f2f4f','fe1c946c-20e4-4b2e-a8e3-262a68028a05','6c43d190-77c5-4181-9199-2fd4aedc6eca','69d4a23c-e719-4bb2-ae3e-b246aad0fb26','28d41cd2-5b22-4274-bcb7-3c3a9f60d8d3','bf23cd18-31a5-487f-9307-89cf42498f7c','0afba4a6-bfa9-4a0e-a2bd-ff0cd043e63b','a6ba7d45-bc86-4f59-a074-8662f1ef5afb','ab045817-cd37-4d97-8746-1360e9167aa0','7675bc34-226e-4167-9a96-2a9e72fbf54e','352afee2-99fa-4e03-80aa-ed0f048e8bba','6dd72abe-76a2-4f26-9fdf-f44cf770355b','2d5215b4-e73d-47f6-9f93-a6cd536f7104','a2fd6662-0ba0-4cef-8bff-8b452cc2621b','ebcf9d09-80fe-49ae-a436-13121457b187','dfddd854-f54d-450d-809a-0382e085b940','b4921ef3-64cc-414f-a9a7-fabf0526674f','eb3f1683-c83c-44cf-88c9-9280bb9c7f48','cd3f8244-5768-4cbf-8335-fc37fb6f4817','0d6f30f2-44b1-4f47-a6c8-7d36c7f5b637','07712e10-10e2-461b-9546-81571b357d91','c61cd49b-3a0c-4d60-ba54-3f72ce356c50','fbdd9f04-49ed-4fd7-a850-0e8a8462433b','90f54d44-5e4b-41c7-86a6-b9c080b8598f','d4721f0d-1c90-4005-8edf-6f52e0e402fc','9f5056ba-04bb-4b3a-8348-3c906b663a32','f70a8636-27a3-436c-966b-54e685ce3d8a','7e72932f-2f7c-4bb2-be09-3ce307a53eca','759cc67a-f7d8-4154-85bf-6308cc4fd3c7','85c05448-eef8-42ac-8be2-1207d1cd51b2','edeffbf7-075d-4876-9291-5bb5b188f9dd','8573b8e9-9fb0-4646-8744-bd5b2c210d20','ec709ab5-40c7-4453-839d-3f08fc655cb0','1f951e17-895a-4c6a-9d65-7898349a3513','cce2fd2c-dc12-42db-ad0b-087ba4d9e163','91f94d7e-da0c-442b-be76-c6b579d5d79b','6d379d69-5eb1-447a-b0ed-86542c2bf086','38f0409f-046e-41ed-a458-0700450f0baa','1a8e580f-fa75-4133-b13b-e1de32cb4159','abee8c2f-69cc-41e8-920e-2f79414fec3c','c2d67642-187b-48c3-bef9-d47a33b6f7d7','6b234368-1a5d-4dbc-b6d5-428edd0ceaf1','604af7b0-91b2-4ab3-abb6-af359c088f5e','7771d693-073f-4c9c-98a8-8b1fe104e308','fda4068f-6c4e-4898-9790-089cef6bd27e','ae3b0198-93ea-4c71-9393-037a2dddfc7f','676d68c6-b645-4e83-9abf-bcef9f0cf0ab','d06be417-5e8f-422c-98ab-ff7392067118','63e12b24-e7d0-494c-bfd2-75c8a57f1f14','505e8ed6-170f-4684-88e2-7aaeee338897','8784d90d-687d-4a89-b5f6-e3e3ea59dc92','8c82e80f-ecd0-42b6-a7fb-e66d99b4a0ae','b10160a8-2f2f-4a03-b4ae-0f53a87d3482','540b569e-2117-47bd-b336-a5032d8bc637','83fe5bfa-6159-47cf-afb6-24812dcb1b1e','6901e566-734b-40b6-830b-3f196ad8671e','11edb1fd-2e04-4e46-b69a-b8ba6f6fa0ab','fce6348e-4a3a-4445-a7d6-ca9922703e7e','c1f8baeb-e060-4759-8698-c55ba9c93dfb','9e27ae0f-e8e0-4c46-a467-193338d6b0cd','2c5167ba-1e3b-41b4-9ae4-bc7ff22972d0','e20cd43b-7030-4534-955e-2c5f841266af','abdef807-4a47-4e44-982b-4232f7cf3e42','12bb23de-da64-4319-864f-da7174c4060f','c8120e9a-2252-4b68-9e37-0e0007599c3e','209fb22d-867c-4146-933f-189c9e7f8530','bfc7fb9f-d8b4-456a-8c7a-ceb4c9013d27','3b99fa3f-86e8-4c0d-a938-b5ec219cbd5c','9cd5106c-02cc-495a-b31d-2d038b13b089','68c63320-7056-4eac-b4f4-f8fce4216723','b93b8b97-4ab4-4064-a56d-f57b9482a090','5e81737a-660a-4f82-831e-bc7cfae6336b','00009270-5ebe-425e-9709-c6c5e5bc2251','2e533a65-f711-44c1-a95b-f65dca10788a','f99ad5ee-edba-4129-bc03-39f119e3bcee','d79accb3-c3d6-4719-88ee-67e4cc825c6a','7c939c31-7990-4d77-9539-23b96fdd2f90','7e60a1d4-e14e-4d15-84b2-8f2dfa7d6d9f','72f4dec9-acfc-4a3e-a428-94170b0fb739','17e8e7f2-46ac-4ee7-8101-872213a78a9d','349b2e0b-4bae-41e5-a111-ea06f38950a7','ad7f3524-f541-4e38-bd9c-b8db95b69b8f','eb71d589-a890-4cd5-a2e0-030e8d4d1687','d94e7484-7e2d-4395-831b-2d5a7960572d','9313040a-d11e-424a-8719-c934b89859f1','1ad6e4f7-7a14-4457-a0cd-0a8f692fb21c','c2590213-25a3-4855-a432-b658ff3d2549','795b465a-13ad-4403-943a-f37e75611186','22fb1871-947d-4aaa-a3b8-56c6abc997ee','fcc18a61-875a-4f8e-b0a4-938698c67e26','d207d5c2-59a3-4c48-bee4-43c6750ebcd9','8ff5bc25-98cb-482d-9763-3de96655abaa','b562ff88-b82b-4079-aac8-6e4c8e6d3503','48dc2b3f-1666-45a1-bc7e-7e764e8dd4d7','00b53aab-7e5f-47af-8828-f3a699305b10','fb021750-ec9e-4045-912e-cc2d693c3476','bfbd4862-76e8-436c-9612-2ffb0b69ff38','2b9f8efd-b523-4916-b417-2b1113aad92a','4008f14e-656c-4296-8b68-2e612f001b16','e553e264-cb35-4855-8631-5596ec5c0842','e75ff6c1-18c6-4540-be44-6769e57b5840','a7c49239-7198-4846-aca6-95e5db5e5305','6e25c249-96f4-4995-9f9c-7c12de91858b','327647cb-3159-4779-a805-1e1b6db0393c','2440538e-0779-4dec-aed6-7097b17403ce','46c340f2-dc0d-4973-819e-2b070874140c','2a482035-d8da-40ab-8931-cdcc7719e696','0a9b5d19-addc-4395-a3c6-02d72113ec8f','c6c16f6d-18f4-45d5-83d1-b5cbe240539d','a78211e5-b774-4550-9b3a-725c99383008','9f80c7ed-b010-40c5-b70f-06ef41a4c09f','1cf56bdb-a12e-4800-bb8b-c17116785821','f2eaf67a-9206-4601-a935-4fed28af2cee','5fe80b2c-ca99-4125-b738-6196508d5a2a','fa477290-72a6-456f-bdf0-478e2a34aaed','7c07c341-1ffe-40ff-b094-e13db0ac78d6','b4585da6-a23e-4628-ad2a-c156ed862007','a6d71a02-3ceb-49f8-abfc-e8f14eb8da7e','3351da29-27f7-4bae-95dc-2978c9f5534c','b358d543-97ac-419e-96a5-344a4f2b1061','58413590-6f3b-420d-b95a-57fb84cf9dd7','1d8dd0e1-8089-44ba-a9cd-71f9a085b862','10387ccd-0084-4e03-8a47-937f396e430a','0efa0adb-137b-41d3-924c-97bccc69edaa','8aa48bd7-d3a6-4362-8701-f7524e60da0e','065a660b-8367-44d1-90aa-7e8398ca6d9a','0fe3219f-b3d4-4e89-a130-6153e7d13310','21342291-8f17-4079-8df5-4251e3305edd','4aa474e2-249b-4ad5-a1df-68dce1816a49','81791dd3-25e6-4e4b-beee-56bdaf6b440c','788f150b-8cdb-432c-80f5-c8948f4c61db','ab4a74b3-6b4e-491f-8832-36b8e93fc61a','83fdab2b-85f0-4605-aae5-09996482edf3','673a3bfd-c385-450b-b318-c3073267c76e','9a141b5c-b09f-4d4e-a229-00c8ef849f83','fa052545-5f4b-47cb-9292-8259509862c7','5584b0b4-b777-4626-955f-2899fb854316','8bea04c0-79cf-401a-83a3-cb15a06e6892','71807cdb-c4cf-4ec5-9993-879b803917ce','dd3afb1f-aa10-48ac-9f9c-4eee4188de4f','ab1e7972-280e-43ae-a923-0daffad99fa9','77086643-3937-42bd-aad0-47a99e46bbb4','25dd03f9-d785-4da5-af4b-4c02d692d185','6e4ffcaa-d577-4db9-983c-d9ff36da3410','0ae3df9a-c7e5-43a0-b10b-5e54270790e7','69a12efe-0ed2-406a-ade6-fcdb6941ccff','e01d4c77-8e71-4a7b-bc8c-e31e3ab7f867','6be16897-9dbb-4ab3-8923-e3bb63fc19d0','a7e35768-194b-404f-921b-40e93eb56f69','c4c86d1e-8e6d-4463-a2de-854878694657','a8531a0c-9fd1-4d2e-9271-e086c0183c69','b6dc4705-912f-4d76-8c6a-c194f244375e','d74a14ef-0fb0-4640-a5fa-c490b38bfa47','f96d8406-50ce-48bd-8f72-3013ad0decf4','a4a6ea72-bb63-46aa-b96d-185e75bfd4dc','bda757e6-fab4-494f-abbf-bce7bbaec71a','dec41e55-d496-4a84-8419-9f1d76050c19','ab499317-b7ca-4a66-97ae-55d698491972','2ee508ba-dd64-45a4-868b-2137713e9e29','5737f0f1-7e01-4189-b92b-b68e88e4cb45','d8f064ad-f01a-4e7b-a739-76553becb59b','2e26a377-c153-400d-a133-7181e4a11f72','dbc4f1a7-5315-46ee-978f-7c26ed7f4e35','fda4de82-7f1e-430d-8c97-b2643c51a782','c18a74e7-71c3-4661-9aa6-0197e714c5bb','d9bcc11b-7b41-4058-8ae1-44f3e932d697','bb9bdf20-0877-4cef-b7c4-b0964e77cfd6','6904d444-9352-4e22-9e14-ed810997a159','3d93151e-8a37-46e2-9631-fade6750c4db','35862c5b-82b3-4375-81b5-d693828d51c7','5b8f56c5-7afb-42c7-98c4-a0be2fdf503a','527bd7e8-7ffc-4b3d-9eab-e633acdb020e','7a3453ba-c3be-48c9-820a-209e28f4dbdd','9642f623-08b3-4eee-88ea-518126bac9b1','8a3dedcb-7edf-4f15-b5b4-8c1d5ad1197c','1448c29f-b251-461f-aa6a-5c0383439032','57f63018-73ed-4442-a02c-3094ecaa03cb','92ac9503-16d2-45bb-a507-6a663c1978a9','28f725de-4812-4b8f-ab85-80de5fa433d9','a18c03fb-4af1-4a97-9494-49e64a7ec516','9dd8e3e4-68aa-48f7-9249-5b740724a119','30abcbdc-f98a-4118-a784-2f686e97e635','92740164-057c-4b70-81d5-ed1c8ef04637','b85ea1d6-39bf-4c6b-add7-3e60b9fd504a','584394be-fe6b-43f4-bbc5-1887e4cd5a81','67b679c4-85b1-4d2c-acc3-e42b31ad78af','576656d4-09bd-41aa-a3b8-d6d13ee0f77c','084b242a-3574-430e-a431-fa69a6c7b87c','225f1daa-d72f-4327-a035-8d1e30fd73ad','57cbe16d-439a-4f22-a764-063f9867fc0e','b02a6aff-8865-4def-8657-82866640118c','920d2870-d742-4203-970e-ac0e6f4c5bf4','f809ab3f-f6fe-4439-a067-ca568440123d','ed8a56d6-c399-49c9-bfe9-f6b96be96992','8a677011-3df9-4a58-ba7d-9f4f4c3cc28e','9a2bb0bf-40c9-477e-aba6-06e179d5ed8c','e0d46fc8-2195-4359-8177-ea406b321169','2861a88c-c383-4c36-9dca-08753074ae29','028c7a73-72c2-44a9-8d8d-0aa1d30371b3','3d50b7b4-5b13-4374-8449-fe2bff01062d','7ec1caa7-53d7-4401-b75f-185764af94ac','94d9994b-a7eb-4723-930d-588b7e0e35df','8bd008a5-f459-4d0f-ab71-7cc7cd6a3285','82e9ce88-12e1-447b-aaae-529c65cf7861','c6b62a05-710a-4567-827b-811b0e3a33e0','e79a24ac-7a00-4727-b523-47c8e7828011','dfdcab3f-009a-4cea-88fd-2dea93785250','1fd3e60e-bbc2-4d8c-8e97-3dfaf4d47c81','8ed813fe-9ede-4642-80cc-447fc8474f2d','6c040db2-93a7-4e47-aae9-e94a40e6b91f','9d7fcfa5-d0ce-47e8-8aae-127e07fc29ab','9475a2a7-0750-4b10-9e6c-46f0d86c4093','6f6aa379-dd63-42c5-9045-66e6809783a2','1182b386-17ef-45e0-a9b3-1bfcfaae62f3','fdc5f30e-1c3a-461c-be4f-8166054422e9','b414dfa7-5777-4b80-93b0-6646e133fd51','72ba350c-5910-4384-b347-1c746822772b','fd770e5e-6ee2-4faf-adae-c7adad2696ad','1f2130c6-c91a-43a5-bebb-7d3833f96563','3be94314-1760-41db-84cd-74d9693cdb06','6e315261-786d-41a8-9829-7fe0c8519b50','ed42d4e4-cd9e-478a-9aa2-557ee8eba914','e1607c39-d2bc-4804-b9c4-663b2b1100dc','aaaf7f73-b034-4e5c-9252-69e208b170ca','3db2f64e-8f74-43aa-922e-477b19d25a82','7d7f350f-7115-417a-931a-7ed8e2713290','612237ce-7642-4b88-975d-31f9a1158ab4','26615b6a-1e79-4fe5-b246-c33ec4a5725e','1edfaad8-470f-4239-9179-2add1c288949','e75b280f-dd8a-4475-a299-93f532f56485','d13f139f-32c0-4dd8-aabb-ebec2f74a844','6a31d7c1-dbdc-43a3-bdcd-b93a234b40b0','8b84fb61-971b-41ce-888a-1353688d75a6','e12db654-a772-41df-ac70-4845dcb92315','4da05652-e9fe-409f-a04f-351bf39c13c1','c49717e1-1238-4564-8b93-9a7cd3578bfb','7dbd3e32-1006-4d76-9286-6b27c8937db4','77e01b8a-afd7-4d4a-baa6-8d897f5a8baa','29957530-7e7e-4633-9213-26bad31caa00','4c435e87-f929-4b8e-8ba1-9ca35dd660bb','52bf360c-2faf-4a43-9f5a-180625e2064b','a0a00581-2874-4cf5-bc46-b4bc64e35198','b0ac0a5c-1305-42c7-b4ad-8b73f4f24948','196c5bce-6337-4426-b4e3-fd965efdd477','2ab3db57-a613-4375-8a3e-2f8514546b0a','4dc975bc-537b-4ec7-a45b-4485597c523d','808addfb-8f53-4d51-9bb6-a77d2940bd3a','741300b8-9b38-4e01-9325-e95a60545b37','0087fd9c-b5fa-4bdc-a6d2-1a2e42e73913','20822bbd-c31f-43a8-8963-be1388bf0686','23c00d78-1240-4fa9-a659-1edf5c0d720a','785e987e-92fa-413f-abde-9f0567c07d0b','9a0a5f1f-9e33-4df3-9f6f-82ba0e08ba44','2723e0e5-ab91-4a01-aba5-8360a23d36b3','a4ae6356-27f2-4276-b1e4-e2d20f85db5d','764c48bb-2b61-4aae-b35a-4a69f708665b','2496c0bf-72f4-4dda-9abd-a2d8a29c1461']

to_void = []
xero_ids.each do |id|
	to_void << xero.Invoice.build(:id => id, :status => 'VOIDED')
end;


require 'open-uri'

tokens='ycaehdntt3do6geduqkm'

record_bank_transfer 'yo45kkbfl,m6fecglofu'
def record_bank_transfer(tokens, acct=103, chunk=25)

	hold_accts=['1923-100 30245139','1062-150 10400516']

	xero = Xeroizer::PrivateApplication.new(Rails.application.config.subs_xero_key, Rails.application.config.subs_xero_secret, Rails.root.join('lib/integrations/xero/certs/privatekey.pem'))
	contact = xero.Contact.all(:where => {:name => "Triage of Funds"}).first
	buffer = { xero.BankTransaction => [] }

	tokens = tokens.split(',') if !tokens.is_a? Array
	tokens.each do |aba_name|

		doc = Document.where("tags LIKE '%aba%'").where("data LIKE '%/#{aba_name}%.aba'")

		if doc.blank?
			RakeHelper::rputs "No ABA Document found for #{aba_name}"
			next;
		elsif doc.count != 1
			RakeHelper::rputs "There seems to be #{doc.count} ABA Documents for #{aba_name}; skipping"
			next;
		else
			doc = doc.last
		end

		aba_name = doc.data.file.public_id # note; this overrides a possibly shorten aba hash..
		#RakeHelper::gputs "ABA found, processing #{aba_name}.."
		

		##
		## Retrieve document
		##
		file = open(doc.data.url){|f| f.read }
		aba_lines = file.split("\n")
		aba_date = aba_lines.first[74..79]
		aba_total = aba_lines.last[32..39].to_f/100
		aba_to_hold = nil;
		
		if aba_date[0..1] == doc.created_at.year.to_s[2..3]
			aba_date = Date.new(2000 + aba_date[0..1].to_i, aba_date[2..3].to_i, aba_date[4..5].to_i)
		else
			aba_date = Date.new(2000 + aba_date[4..5].to_i, aba_date[2..3].to_i, aba_date[0..1].to_i)
		end

		##
		## Attempt to find Xero Invoice
		##
		bt = xero.BankTransaction.all(:where => {:reference => aba_name}).first

		if bt.present? && [false,nil].include?(bt.is_reconciled)
		
			RakeHelper::pputs "Transaction '#{aba_name}' exists, attempting override"
			

			# note; it appears that xero automatically ADDS line items unless we have pulled 
			# the original ones first. Only then will it override the line_items
			bt.line_items.count
			
			skip=false
		
		elsif bt.present? && bt.is_reconciled == true

			RakeHelper::rputs "Transaction '#{aba_name}' is marked as PAID. To update, it must first be unreconciled. Skipping."
			RakeHelper::rputs "https://go.xero.com/Bank/ViewTransaction.aspx?bankTransactionID=#{bt.id}"

			skip=true

		else

			RakeHelper::pputs "Creating transaction '#{aba_name}' for #{aba_total}"
			bt = xero.BankTransaction.build(
								:type => "SPEND",
								:contact => contact,
								:date => aba_date,
								:reference => aba_name,
								:bank_account => { :code => acct }
							)

			skip=false
		
		end

		if !skip

			## If this is a new record, we need to save first before we can attach a file to it

			bt.bank_account = { :code => acct }
			bt.contact = contact
			bt.line_amount_types = "NoTax"
			bt.status = "AUTHORISED"
			bt.line_items = Array.new

			## Add Line Items to Xero Invoice
			aba_lines.each do |line|

				aba_line_type = line[18..19]

				next unless aba_line_type == "50"

				co = line[30..61]
				desc = line[62..79]
				amt = line[22..29].to_f/100
				bank = "BSB #{line[1..7]}, ACCT #{line[8..16]}"

				bt.add_line_item({
					:quantity => 1,
					:unit_amount => amt,
					:description => "#{co}\nRef: #{desc}\n#{bank}",
					:account_code => hold_accts.include?(line[0..16]) ? '803b' : '803a',
					:item_code => hold_accts.include?(line[0..16]) ? nil : 'GOODS'
				})

			end


			if bt.id.nil? && bt.save
				bt = xero.BankTransaction.all(:where => {:reference => aba_name}).first
				bt.attach_data("#{aba_name}.aba.txt", file, "text/plain");
			else
				buffer[xero.BankTransaction] << bt
			end

			RakeHelper::pputs "Transaction #{aba_name} updated, #{aba_total}"
		else
			RakeHelper::yputs "Transaction #{aba_name} updated, #{aba_total}" ,'!'
		end


		buffer = xero_save_buffer buffer, {chunk:chunk, force:/#{tokens.last}.*/.match(aba_name) }
		
		sleep(2)
		
	end
end

def xero_save_buffer buffer, options={}
	options.reverse_merge!(
		:chunk => 3,
		:force => false
	)

	buffer.each do |obj,records|
		if (records.count >= options[:chunk] || (records.count > 0 && options[:force]))
			to_save = options[:force] ? records : records.last(options[:chunk])
			puts "#{to_save.count} #{obj.model_name} of #{records.count}"
			if obj.save_records(to_save.flatten) == false
				RakeHelper::rputs "Error saving #{to_save.count} #{obj.model_name}s into Xero (with force:#{options[:force].to_s})"
				#to_save.reverse.each do |ts|
				#	puts ts.inspect
					#obj.save_records([ts].flatten)
				#end
			else
				RakeHelper::gputs "Saved #{to_save.count} #{obj.model_name}s into Xero (with force:#{options[:force].to_s})"
				buffer[obj] -= to_save
			end
			puts "#{buffer[obj].count} #{obj.model_name}s remain"
		end
	end
	return buffer
end

def ttt(token)
	xero = Xeroizer::PrivateApplication.new(Rails.application.config.subs_xero_key, Rails.application.config.subs_xero_secret, Rails.root.join('lib/integrations/xero/certs/privatekey.pem'))
	contact = xero.Contact.all(:where => {:name => "Triage of Funds"}).first
	xero_records = []

	tokens = token.split(',')
	tokens.each_with_index do |aba_name,idx|

		doc = Document.where("tags LIKE '%aba%'").where("data LIKE '%/#{aba_name}%.aba'")

		if doc.blank?
			RakeHelper::rputs "No ABA Document found for #{aba_name}"
			next;
		elsif doc.count != 1
			RakeHelper::rputs "There seems to be #{doc.count} ABA Documents for #{aba_name}; skipping"
			next;
		else
			doc = doc.last
		end

		aba_name = doc.data.file.public_id # note; this overrides a possibly shorten aba hash..
		RakeHelper::gputs "ABA found, processing #{aba_name}.."

		##
		## Retrieve document
		##
		file = open(doc.data.url){|f| f.read }
		aba_lines = file.split("\n")
		aba_date = aba_lines.first[74..79]
		aba_total = aba_lines.last[22..29].to_f/100
		aba_to_hold = nil;
		
		if aba_date[0..1] == doc.created_at.year.to_s[2..3]
			aba_date = Date.new(2000 + aba_date[0..1].to_i, aba_date[2..3].to_i, aba_date[4..5].to_i)
		else
			aba_date = Date.new(2000 + aba_date[4..5].to_i, aba_date[2..3].to_i, aba_date[0..1].to_i)
		end


		##
		## Attempt to find Xero Invoice
		##
		skip_accpay = false
		inv_accpay = xero.Invoice.all(:where => {:invoice_number => "ACCPAY #{aba_name}"}).first

		if inv_accpay.present? && inv_accpay.status != "PAID"
		
			RakeHelper::pputs "Found 'ACCPAY #{aba_name}', attempting override"
			inv_accpay.contact = contact
			inv_accpay.line_amount_types = "Inclusive"
			inv_accpay.status = "AUTHORISED"

			# note; it appears that xero automatically ADDS line items unless we have pulled 
			# the original ones first. Only then will it override the line_items
			inv_accpay.line_items.count 
		
		elsif inv_accpay.present? && inv_accpay.status == "PAID"

			RakeHelper::rputs "Invoice 'ACCPAY #{aba_name}' is marked as PAID. To update, it must first be unreconciled. Skipping."
			skip_accpay = true

		else

			RakeHelper::pputs "Creating 'ACCPAY #{aba_name}' for #{aba_total}"
			inv_accpay = xero.Invoice.build(
								:type => "ACCPAY",
								:contact => contact,
								:date => aba_date,
								:due_date => aba_date,
								:invoice_number => "ACCPAY #{aba_name}",
								:line_amount_types => "Inclusive",
								:status => "AUTHORISED"
							)
		
		end

		inv_accpay.line_items = Array.new

		## Add Line Items to Xero Invoice
		aba_lines[1..aba_lines.count-2].each do |line|

			co = line[30..61]
			desc = line[62..79]
			amt = line[22..29].to_f/100
			bank = "BSB #{line[1..7]}, ACCT #{line[8..16]}"

			inv_accpay.add_line_item({
				:quantity => 1,
				:unit_amount => amt,
				:description => "#{co}\nRef: #{desc}\n#{bank}",
				:account_code => line[0..16] == "1062-150 10400516" ? '803b' : '803a',
				:item_code => line[0..16] == "1062-150 10400516" ? nil : 'GOODS'
			})

			aba_to_hold = amt if line[0..16] == "1062-150 10400516"

		end

		if !skip_accpay
			inv_accpay.save
			inv_accpay.attach_data("#{aba_name}.aba.txt", file, "text/plain");
			xero_records << inv_accpay
			RakeHelper::pputs "ACCPAY #{aba_name} updated, #{aba_total}"
		end
		
		if false && aba_to_hold.present?

			skip_accrec = false
			inv_accrec = xero.Invoice.all(:where => {:invoice_number => "ACCREC #{aba_name}"}).first

			if inv_accrec.present? && inv_accrec.status != "PAID"
				
				RakeHelper::pputs "Found 'ACCREC #{aba_name}', attempting override"
				inv_accrec.contact = contact
				inv_accrec.line_amount_types = "Inclusive"
				inv_accrec.status = "AUTHORISED"

				# note; it appears that xero automatically ADDS line items unless we have pulled 
				# the original ones first. Only then will it override the line_items
				inv_accrec.line_items.count

			elsif inv_accrec.present? && inv_accrec.status == "PAID"

				RakeHelper::rputs "Invoice 'ACCREC #{aba_name}' is marked as PAID. To update, it must first be unreconciled. Skipping."
				skip_accrec = true
			
			else
				
				RakeHelper::pputs "Creating 'ACCREC #{aba_name}' for #{aba_to_hold}"
				inv_accrec = xero.Invoice.build(
									:type => "ACCREC",
									:contact => contact,
									:date => aba_date,
									:due_date => aba_date,
									:invoice_number => "ACCREC #{aba_name}",
									:line_amount_types => "Inclusive",
									:status => "AUTHORISED"
								)
			end

			inv_accrec.line_items = Array.new

			inv_accrec.add_line_item({
				:quantity => 1,
				:unit_amount => aba_to_hold,
				:description => "Funds withheld",
				:account_code => '803b'
			})

			if !skip_accrec
				inv_accrec.save
				inv_accrec.attach_data("#{aba_name}.aba.txt", file, "text/plain")
				xero_records << inv_accrec
				RakeHelper::pputs "ACCREC #{aba_name} updated, #{aba_to_hold}"
			end

			if tokens.count - 1 != idx
				sleep(5)
			end
		end
	end

	#if xero.Invoice.save_records(xero_records.flatten) == false
	#	RakeHelper::rputs "Error saving #{xero_records.count} records into Xero"
	#else
	RakeHelper::gputs "Saved #{xero_records.count} records into Xero"
	#end
end

$learning_accounts = {
	"Subscribility"=>"200",
	"Stripe"=>"201",
	"UPS"=>"201",
	"Tasting Experience and Show"=>"201",
	"Mailchimp"=>"201",
	"Activity Summary"=>"201",
	"FedEx"=>"201",
	"WordPress Ecommerce"=>"201",
	"Australia Post"=>"201",
	"Online Payments"=>"202",
	"Text Messaging"=>"201",
	"Data Export"=>"201",
	"Fastway Prepaid"=>"201",
	"CommWeb"=>"201",
	"eWAY"=>"201",
	"translation missing: en-AU.integration.provider.FedEx"=>"201",
	"translation missing: en-AU.integration.provider.Stripe"=>"201",
	"WordPress"=>"201",
	"Gmail"=>"201",
	"Couriers Please Prepaid"=>"201"
}

def define_xero_acc name, qty, subtotal, ol=nil
	acct=nil
	case name
		when *$learning_accounts.keys
			acct = $learning_accounts[name]
		when /^Subscribility$/, /^Platform access fee$/
			acct=200
		when /\d* payments processed$/, /\d* shipments dispatched$/, /\d* data syncs$/, /\d* orders completed$/, /\d* Payment processed$/, /^Usage fee/
			acct=201
		when /\d* payment provider transaction fees$/
			acct=202
		when /\d* shipping provider transaction fees$/
			acct=203
		when /\d* SMS sent$/, /^SMS$/, /^\d* SMS provider transaction fees$/
			acct=204
		when /.*Support.*/, /.*Implementation.*/, /.* integration configuration$/, /^Setup.*/
			acct=259
		when /Monies owed to Subscribility/
			acct=260
		when /^Funds withheld$/, /^Payments made to providers$/
			acct=620
		when /Subscribility account credit/
			acct=415
	end

	if acct.nil?
		puts ol.inspect
		acct = RakeHelper::pick_from_array({
			200=>'SAAS - Membership Income',
			201=>'SAAS - Usage Fee Income',
			202=>'BANKING - Surcharge Income',
			203=>'SHIPPING - Surcharge Income',
			204=>'SMS - Surcharge Income',
			257=>'WEB - Web Hosting Income',
			258=>'WEB - Web Development Income',
			259=>'SAAS - Implementation & Support Services',
			998=>'XX - Skip Line',
			999=>'XX - Skip Invoice',
			},"What should be the account number for '#{name}' (at $#{subtotal})?")
		$learning_accounts[name] = acct
	end

	return acct
end

session=RakeHelper::init_google_session
wsheet=RakeHelper::init_google_worksheet nil, '2014-2016 P&L Worksheet', session

def invoices_to_google from=nil

	#xero = Xeroizer::PrivateApplication.new(Rails.application.config.subs_xero_key, Rails.application.config.subs_xero_secret, Rails.root.join('lib/integrations/xero/certs/privatekey.pem'))

	cids = Company.where(:is_fake => false).pluck(:id)
	invoices = Invoice.where(:customer_id => nil,:company_id => cids, :payment_status => 'completed')
	invoices = invoices.where('issued_at >= :date OR update_at >= :date',:date => from) if from.present?
	invoices = invoices.order(:issued_at)

	_from = from.present? ? " (from: #{from})" : ''
	dputs "Pushing invoices to GDoc#{_from}"

	j=0
	invoices.each do |i|

		RakeHelper::pputs i.issued_at		

		i.orders.first.orderlines.where(:display_only => false).each do |ol|

			acct = define_xero_acc(ol.name,ol.qty,ol.subtotal,ol)
			data = {
				"Number" => i.number,
				"Date" => i.issued_at,
				"Description" => ol.name,
				"Account" => acct,
				"Value" => ol.subtotal.to_f
			}

			wsheet = RakeHelper::set_wsheet_row(wsheet, j, data)
			j += 1
		end
	end;
	wsheet.save
end;






## Pushes all winery invoices to Xero from a specific date and/or specific numbers
##
##
def push_invoices(options={})

	options.reverse_merge!(
		:from => nil, 					## Startng date range, defaults to 1970
		:to => nil, 					## End date range, defaults to NOW
		:include_numbers => [],	## Specific invoice numbers, as array or comma-separated list
		:skip_numbers => [],		## Invoice numbers to skip, as array or comma-separated list
	);

	options[:include_numbers] = options[:include_numbers].split(',').map { |x| x.strip } if options[:include_numbers].present? && options[:include_numbers].is_a?(String);
	options[:skip_numbers] = options[:skip_numbers].split(',').map { |x| x.strip } if options[:skip_numbers].present? && options[:skip_numbers].is_a?(String);
	
	processed_numbers = []

	xero = Xeroizer::PrivateApplication.new(Rails.application.config.subs_xero_key, Rails.application.config.subs_xero_secret, Rails.root.join('lib/integrations/xero/certs/privatekey.pem'))

	save_buffer = { xero.Invoice => [], xero.Payment => [] };

	cids = Company.where(:is_fake => false).pluck(:id);
	invoices = Invoice.where(:customer_id => nil,:company_id => cids, :payment_status => 'completed');

	invoices = invoices.where('issued_at >= :date OR updated_at >= :date',:date => options[:from]) if options[:from].present?;
	invoices = invoices.where('issued_at <= :date OR updated_at <= :date',:date => options[:to]) if options[:to].present?;
	invoices = invoices.where(:number => options[:include_numbers]) if options[:include_numbers].present?;
	invoices = invoices.where.not(:number => options[:skip_numbers]) if options[:skip_numbers].present?;
	
	invoices = invoices.order(:issued_at);

	RakeHelper::dputs "Pushing invoices to Xero (#{options[:from] || 'begining of time'} to #{options[:to] || 'now'}, #{options[:include_numbers].present? ? options[:include_numbers].join(', ') : 'all numbers'})"

	invoices.each do |i|

		processed_numbers << i.number
		
		RakeHelper::pputs "Processing #{i.number}"
		
		x_i = xero.Invoice.all(:where => {:type => "ACCREC", :invoice_number => i.number}).last || xero.Invoice.build(:type => "ACCREC", :invoice_number => i.number)

		if x_i.status == 'PAID'
			RakeHelper::yputs("PAID IN FULL: Cannot process invoice #{i.number} for #{i.company.legal_name}. Skipping.", '→')
			next;
		end

		if i.company.provider_data[:external_ids][:xero].present?
			x_i.contact = xero.Contact.build(:id => i.company.provider_data[:external_ids][:xero])
		else
			x_i.contact = xero.Contact.all(:where => {:contact_number => i.company_id}).first
		end

		x_i.date = i.issued_at
		x_i.due_date = (i.issued_at + 2.days)
		x_i.status = 'DRAFT'

		x_i.line_items.count
		x_i.line_items = Array.new

		#invoice.line_amount_types = ['NSW','VIC','TAS'].include? i.company.state ? 'Exclusive' : 'NoTax'
		x_i.line_amount_types = 'NoTax'

		catch :skip_invoice do
			
			i.orders.first.orderlines.where(:display_only => false).each do |ol|

				acct = define_xero_acc(ol.name,ol.qty,ol.subtotal,ol)

				next 						if acct == 998
				throw :skip_invoice 		if acct == 999
				
				if acct == 620

					identifier = "OID:#{ol.order_id}, OLID:#{ol.id}"

					if x_i.id.nil? && (x_i.save == false || (x_i = xero.Invoice.all(:where => {:type => "ACCREC", :invoice_number => i.number}).last).blank?)

						RakeHelper::yputs("Invoice #{i.number} a prepayment registered and is currently being created in Xero. Run this again to ensure prepayment is recorded.","!")
						
						processed_numbers.delete(i.number)

					elsif x_i.payments.select{ |payment| payment.reference == identifier }.present?

						RakeHelper::pputs "Prepayment of $#{ol.price.abs} on invoice #{i.number} already recorded. Skipping."

					else	

						x_i.status = 'AUTHORISED'

						RakeHelper::pputs "Recording prepayment of $#{ol.price.abs} as '#{ol.name}' against invoice #{i.number} (#{acct})"
						payment=xero.Payment.build(:amount => ol.price.abs, :date => x_i.date, :status =>'AUTHORISED', :invoice => {:id => x_i.id}, :reference => identifier, :account => {:code => acct})
						save_buffer[xero.Payment] << payment

					end

					x_i.add_line_item({
						:quantity => 1,
						:unit_amount => 0,
						:description => "#{ol.name} (#{ol.price.abs})",
						:account_code => acct
					})

				else
					
					x_i.add_line_item({
						:quantity => ol.qty,
						:unit_amount => ol.price.to_f,
						:description => ol.name,
						:account_code => acct
					})

				end
			end

			# register successful Credit Card payments made against that invoice
			i.payments.where(:status => 'success', :trx =>'charge').each do |p|

				identifier = "PID:#{p.id}, RRN:#{p.rrn}"

				if x_i.id.nil? && (x_i.save == false || (x_i = xero.Invoice.all(:where => {:type => "ACCREC", :invoice_number => i.number}).last).blank?)
					
					RakeHelper::yputs("Invoice #{i.number} has payment registered and is currently being created in Xero. Run this again to ensure payment is recorded.","!")

					processed_numbers.delete(i.number)


				elsif x_i.payments.select{ |payment| payment.reference == identifier }.present?

					#RakeHelper::pputs "Payment of $#{ol.subtotal.to_f} on invoice #{i.number} already recorded. Skipping."

				else

					x_i.status = 'AUTHORISED'

					RakeHelper::pputs "Registering payment of $#{p.amount} as '#{identifier}' to against invoice #{i.number} (803c)"
					payment=xero.Payment.build(:amount => p.amount, :date => p.updated_at, :status =>'AUTHORISED', :invoice => {:id => x_i.id}, :reference => identifier, :account => {:code => '803c'})
					save_buffer[xero.Payment] << payment
				end
			end

			save_buffer[xero.Invoice] << x_i
			save_buffer = xero_save_buffer save_buffer, {force:invoices.last.id == i.id } 

		end
		sleep(5);

	end

	return processed_numbers;
end

def push_companies_to_xero from=nil
	
	xero = Xeroizer::PrivateApplication.new(Rails.application.config.subs_xero_key, Rails.application.config.subs_xero_secret, Rails.root.join('lib/integrations/xero/certs/privatekey.pem'))

	save_buffer = { xero.Contact => [] }

	companies = Company.where(:is_fake => false)
	companies = companies.where('created_at > :date OR updated_at > :date',:date => from) if from.present?

	_from = from.present? ? " (from: #{from})" : ''
	dputs "Pushing companies to Xero#{_from}"

	companies.each do |c|

		contact = xero.Contact.all(:where => {:contact_number => c.id}).first

		if contact.nil?
			contact = xero.Contact.build(:name => c.legal_name, :contact_number => c.id)
			RakeHelper::gputs "Creating #{c}"
		else
			c.provider_data ||= {}
			c.provider_data[:external_ids] ||= {}
			c.provider_data[:external_ids][:xero] ||= contact.id
			c.save!
			RakeHelper::pputs "Updating #{c}"
		end

		contact.name = c.legal_name
		contact.name += " - LOCKED" if c.is_locked
		contact.name += " (#{c.id})"
		contact.add_phone(:type => "DEFAULT", :number => c.phone)

		if c.admin_users.where(:company_users => {:is_billing => true}).blank? && 
			(first_admin = c.admin_users.where.not("email LIKE '%empireone%' or email LIKE '%subscribility%'").first).present?
			CompanyUser.where(:user_id => first_admin.id, :company_id => c.id).update_all(:is_billing => true)
			RakeHelper::yputs "Added #{first_admin.email} as billing contact.",'!'
		end

		if (billing_contact = c.admin_users.where(:company_users => {:is_billing => true}).first).present?
		
			contact.email_address = billing_contact.email
			contact.first_name = billing_contact.fname
			contact.last_name = billing_contact.lname
			contact.add_address({
				:type => 'STREET',
				:line1 => c.address,
				:line2 => c.suburb,
				:postal_code => c.postcode,
				:region => c.state
			})
		else
			RakeHelper::rputs "No billing contact found for #{c.business_name}"
		end
		
		save_buffer[xero.Contact] << contact

		save_buffer = xero_save_buffer save_buffer, {force:companies.last.id == c.id } 

		sleep(2)
	end;

end





ok = []
exceptions = ["70101-5700-001","70101-6800-002","70101-14700-001","70201-35200-001","70201-35300-001","70201-35500-001","70201-6800-001","70224-22100-001","70224-35100-001","70301-36200-001","70301-36900-001","70301-37900-001","70301-35200-001","70301-35500-001","70301-35100-001"]
ok = []
exceptions = []
cids = Company.where(:is_fake => false).pluck(:id);
Invoice.where(:company_id => cids, :customer_id => nil, :created_at => Time.new(2016,7,1)..Time.new(2016,9,30)).where.not(:number => ok+exceptions).each do |i|
	sleep(7);
	begin
		ok += push_invoices :include_numbers => i.number
	rescue
		exceptions << i.number
	end
end;

Invoice.where(:customer_id => nil, :created_at => Time.new(2016,10,01)..Time.new(2017,03,15)).where.not(:number => ok).count
Invoice.where(:customer_id => nil, :created_at => Time.new(2016,10,01)..Time.new(2017,03,15)).where.not(:number => ok).each do |i|
	ok += push_invoices :include_numbers => i.number
end;Time.now;


 ["61202-11500-001",
 "61208-2700-001",
 "61208-22500-009",
 "61206-11600-005",
 "61202-32400-001",
 "61202-11000-001",
 "61202-23900-001",
 "61202-28000-001",
 "61202-26800-002",
 "61202-8000-031",
 "61202-12000-001",
 "61202-11900-001",
 "61202-3500-001",
 "61202-3300-005",
 "61202-14700-009",
 "61202-2900-001",
 "61202-7700-001",
 "61202-1300-001",
 "61202-5900-001",
 "61202-8200-002",
 "61202-9100-002",
 "61202-6400-001",
 "61202-5500-001",
 "61202-4400-024",
 "61202-5700-001",
 "61202-22100-001",
 "61202-12600-012",
 "61202-8900-001",
 "61202-8800-002",
 "61202-6800-001",
 "61202-9000-001",
 "61202-6300-001",
 "61202-9300-001",
 "61202-20600-001",
 "61202-24900-001",
 "61202-11200-001",
 "61202-10700-001",
 "61202-9200-001",
 "61202-12500-001",
 "61202-12900-001",
 "61202-10800-001",
 "61202-23400-001",
 "61202-11300-001",
 "61202-8400-001",
 "61202-27900-001",
 "61202-30700-001",
 "70101-34600-001",
 "70101-6400-002",
 "70101-31700-005",
 "70101-33200-001",
 "70101-32400-001",
 "70101-5500-001",
 "70101-2700-001",
 "70101-23900-001",
 "70101-28000-001",
 "70101-4400-001",
 "70101-26800-001",
 "70101-12000-001",
 "70101-11000-001",
 "70101-11900-001",
 "70101-5700-001",
 "70101-11600-015",
 "70101-2900-001",
 "70101-7700-001",
 "70101-8000-001",
 "70101-5900-001",
 "70101-8200-002",
 "70101-8900-001",
 "70101-3500-001",
 "70101-9100-001",
 "70101-22100-001",
 "70101-1700-001",
 "70101-12600-001",
 "70101-8800-001",
 "70101-6300-001",
 "70101-6800-002",
 "70101-9000-001",
 "70101-11500-001",
 "70101-14700-001",
 "70101-9300-001",
 "70101-20600-001",
 "70101-24900-001",
 "70101-10700-001",
 "70101-11200-001",
 "70101-9200-001",
 "70101-12500-001",
 "70101-12900-001",
 "70101-10800-001",
 "70101-23400-001",
 "70101-11300-001",
 "70101-8400-001",
 "70101-27900-001",
 "70101-30700-001",
 "70101-3300-017",
 "70101-22500-001",
 "70110-1300-001",
 "70111-33400-001",
 "70114-26900-001",
 "70114-33800-001",
 "70114-34400-001",
 "70126-21500-001",
 "70126-32500-001",
 "61130-27900-001",
 "61130-30700-001",
 "61201-31700-001",
 "61201-33200-002",
 "61001-8200-002",
 "61001-11900-001",
 "61001-7700-001",
 "61001-3300-039",
 "61001-18700-001",
 "61001-5900-001",
 "61001-2900-001",
 "61001-1300-011",
 "61001-9100-003",
 "61001-14100-001",
 "61001-6400-001",
 "61001-5500-001",
 "61001-4400-001",
 "61001-11000-014",
 "61001-8800-002",
 "61001-8000-001",
 "61001-3500-001",
 "61001-5700-010",
 "61001-22100-001",
 "61001-12600-001",
 "61001-8900-001",
 "61001-6800-002",
 "61001-9000-001",
 "61001-11500-004",
 "61001-22500-064",
 "61001-14700-001",
 "61001-9300-001",
 "61001-6300-001",
 "61001-5800-001",
 "61001-20600-001",
 "61001-24900-001",
 "61001-3400-001",
 "61001-10700-001",
 "61001-11200-001",
 "61001-9200-001",
 "61001-12500-001",
 "61001-12900-001",
 "61001-9800-001",
 "61001-10800-001",
 "61001-23400-001",
 "61013-11300-001",
 "61013-8400-001",
 "61001-11600-031",
 "61001-12000-001",
 "61101-2700-001",
 "61101-8400-001",
 "61101-22500-008",
 "61101-23900-001",
 "61101-28000-001",
 "61101-8000-001",
 "61101-26800-001",
 "61101-12000-001",
 "61101-18700-001",
 "61101-3500-008",
 "61101-11900-001",
 "61101-3300-010",
 "61101-2900-001",
 "61101-7700-001",
 "61101-1300-001",
 "61101-5900-001",
 "61101-8200-007",
 "61101-9100-001",
 "61101-6400-001",
 "61101-5500-001",
 "61101-4400-002",
 "61101-11000-003",
 "61101-11600-004",
 "61101-6300-001",
 "61101-5700-001",
 "61101-22100-001",
 "61101-12600-005",
 "61101-8900-001",
 "61101-6800-497",
 "61101-9300-001",
 "61101-9000-001",
 "61101-11500-001",
 "61101-10700-002",
 "61101-24900-001",
 "61101-14700-002",
 "61001-8200-002",
 "61001-11900-001",
 "61001-7700-001",
 "61001-3300-039",
 "61001-18700-001",
 "61001-5900-001",
 "61001-2900-001",
 "61001-1300-011",
 "61001-9100-003",
 "61001-14100-001",
 "61001-6400-001",
 "61001-5500-001",
 "61001-4400-001",
 "61001-11000-014",
 "61001-8800-002",
 "61001-8000-001",
 "61001-3500-001",
 "61001-5700-010",
 "61001-22100-001",
 "61001-12600-001",
 "61001-8900-001",
 "61001-6800-002",
 "61001-9000-001",
 "61001-11500-004",
 "61001-22500-064",
 "61001-14700-001",
 "61001-9300-001",
 "61001-6300-001",
 "61001-5800-001",
 "61001-20600-001",
 "61001-24900-001",
 "61001-3400-001",
 "61001-10700-001",
 "61001-11200-001",
 "61001-9200-001",
 "61001-12500-001",
 "61001-12900-001",
 "61001-9800-001",
 "61001-10800-001",
 "61001-23400-001",
 "61013-11300-001",
 "61013-8400-001",
 "61001-11600-031",
 "61001-12000-001",
 "61101-2700-001",
 "61101-8400-001",
 "61101-22500-008",
 "61101-23900-001",
 "61101-28000-001",
 "61101-8000-001",
 "61101-26800-001",
 "61101-12000-001",
 "61101-18700-001",
 "61101-3500-008",
 "61101-11900-001",
 "61101-3300-010",
 "61001-8200-002",
 "61001-11900-001",
 "61001-7700-001",
 "61001-3300-039",
 "61001-18700-001",
 "61001-5900-001",
 "61001-2900-001",
 "61001-1300-011",
 "61001-9100-003",
 "61001-14100-001",
 "61001-6400-001",
 "61001-5500-001",
 "61001-4400-001",
 "61001-11000-014",
 "61001-8800-002",
 "61001-8000-001",
 "61001-3500-001",
 "61001-5700-010",
 "61001-22100-001",
 "61001-12600-001",
 "61001-8900-001",
 "61001-6800-002",
 "61001-9000-001",
 "61001-11500-004",
 "61001-22500-064",
 "61001-14700-001",
 "61001-9300-001",
 "61001-6300-001",
 "61001-5800-001",
 "61001-20600-001",
 "61001-24900-001",
 "61001-3400-001",
 "61001-10700-001",
 "61001-11200-001",
 "61001-9200-001",
 "61001-12500-001",
 "61001-12900-001",
 "61001-9800-001",
 "61001-10800-001",
 "61001-23400-001",
 "61013-11300-001",
 "61013-8400-001",
 "61001-11600-031",
 "61001-12000-001",
 "61101-2700-001",
 "61101-8400-001",
 "61101-22500-008",
 "61101-23900-001",
 "61101-28000-001",
 "61101-8000-001",
 "61101-26800-001",
 "61101-12000-001",
 "61001-8200-002",
 "61001-11900-001",
 "61001-7700-001",
 "61001-3300-039",
 "61001-18700-001",
 "61001-5900-001",
 "61001-2900-001",
 "61001-1300-011",
 "61001-9100-003",
 "61001-14100-001",
 "61001-6400-001",
 "61001-5500-001",
 "61001-4400-001",
 "61001-11000-014",
 "61001-8800-002",
 "61001-8000-001",
 "61001-3500-001",
 "61001-5700-010",
 "61001-22100-001",
 "61001-12600-001",
 "61001-8900-001",
 "61001-6800-002",
 "61001-9000-001",
 "61001-11500-004",
 "61001-22500-064",
 "61001-14700-001",
 "61001-9300-001",
 "61001-6300-001",
 "61001-5800-001",
 "61001-20600-001",
 "61001-24900-001",
 "61001-3400-001",
 "61001-10700-001",
 "61001-11200-001",
 "61001-9200-001",
 "61001-12500-001",
 "61001-12900-001",
 "61001-9800-001",
 "61001-10800-001",
 "61001-23400-001",
 "61013-11300-001",
 "61013-8400-001",
 "61001-11600-031",
 "61001-12000-001",
 "61101-2700-001",
 "61101-8400-001",
 "61101-22500-008",
 "61101-23900-001",
 "61101-28000-001",
 "61101-8000-001",
 "61101-26800-001",
 "61101-12000-001",
 "61001-8200-002",
 "61001-11900-001",
 "61001-7700-001",
 "61001-3300-039",
 "61001-18700-001",
 "61001-5900-001",
 "61001-2900-001",
 "61001-1300-011",
 "61001-9100-003",
 "61001-14100-001",
 "61001-6400-001",
 "61001-5500-001",
 "61001-4400-001",
 "61001-11000-014",
 "61001-8800-002",
 "61001-8000-001",
 "61001-3500-001",
 "61001-5700-010",
 "61001-22100-001",
 "61001-12600-001",
 "61001-8900-001",
 "61001-6800-002",
 "61001-9000-001",
 "61001-11500-004",
 "61001-22500-064",
 "61001-14700-001",
 "61001-9300-001",
 "61001-6300-001",
 "61001-5800-001",
 "61001-20600-001",
 "61001-24900-001",
 "61001-3400-001",
 "61001-10700-001",
 "61001-11200-001",
 "61001-9200-001",
 "61001-12500-001",
 "61001-12900-001",
 "61001-9800-001",
 "61001-10800-001",
 "61001-23400-001",
 "61013-11300-001",
 "61013-8400-001",
 "61001-11600-031",
 "61001-12000-001",
 "61101-2700-001",
 "61101-8400-001",
 "61101-22500-008",
 "61101-23900-001",
 "61101-28000-001",
 "61101-8000-001",
 "61101-26800-001",
 "61101-12000-001",
 "61001-8200-002",
 "61001-11900-001",
 "61001-7700-001",
 "61001-3300-039",
 "61001-18700-001",
 "61001-5900-001",
 "61001-2900-001",
 "61001-1300-011",
 "61001-9100-003",
 "61001-14100-001",
 "61001-6400-001",
 "61001-5500-001",
 "61001-4400-001",
 "61001-11000-014",
 "61001-8800-002",
 "61001-8000-001",
 "61001-3500-001",
 "61001-5700-010",
 "61001-22100-001",
 "61001-12600-001",
 "61001-8900-001",
 "61001-6800-002",
 "61001-9000-001",
 "61001-11500-004",
 "61001-22500-064",
 "61001-14700-001",
 "61001-9300-001",
 "61001-6300-001",
 "61001-5800-001",
 "61001-20600-001",
 "61001-24900-001",
 "61001-3400-001",
 "61001-10700-001",
 "61001-11200-001",
 "61001-9200-001",
 "61001-12500-001",
 "61001-12900-001",
 "61001-9800-001",
 "61001-10800-001",
 "61001-23400-001",
 "61013-11300-001",
 "61013-8400-001",
 "61001-11600-031",
 "61001-12000-001",
 "61101-2700-001",
 "61101-8400-001",
 "61101-22500-008",
 "61101-23900-001",
 "61101-28000-001",
 "61101-8000-001",
 "61101-26800-001",
 "61101-12000-001",
 "61101-18700-001",
 "61001-8200-002",
 "61001-11900-001",
 "61001-7700-001",
 "61001-3300-039",
 "61001-18700-001",
 "61001-5900-001",
 "61001-2900-001",
 "61001-1300-011",
 "61001-9100-003",
 "61001-14100-001",
 "61001-6400-001",
 "61001-5500-001",
 "61001-4400-001",
 "61001-11000-014",
 "61001-8800-002",
 "61001-8000-001",
 "61001-3500-001",
 "61001-5700-010",
 "61001-22100-001",
 "61001-12600-001",
 "61001-8900-001",
 "61001-6800-002",
 "61001-9000-001",
 "61001-11500-004",
 "61001-22500-064",
 "61001-14700-001",
 "61001-9300-001",
 "61001-6300-001",
 "61001-5800-001",
 "61001-20600-001",
 "61001-24900-001",
 "61001-3400-001",
 "61001-10700-001",
 "61001-11200-001",
 "61001-9200-001",
 "61001-12500-001",
 "61001-12900-001",
 "61001-9800-001",
 "61001-10800-001",
 "61001-23400-001",
 "61013-11300-001",
 "61013-8400-001",
 "61001-11600-031",
 "61001-12000-001",
 "61101-2700-001",
 "61101-8400-001",
 "61101-22500-008",
 "61101-23900-001",
 "61101-28000-001",
 "61101-8000-001",
 "61101-26800-001",
 "61101-12000-001",
 "61001-8200-002",
 "61001-11900-001",
 "61001-7700-001",
 "61001-3300-039",
 "61001-18700-001",
 "61001-5900-001",
 "61001-2900-001",
 "61001-1300-011",
 "61001-9100-003",
 "61001-14100-001",
 "61001-6400-001",
 "61001-5500-001",
 "61001-4400-001",
 "61001-11000-014",
 "61001-8800-002",
 "61001-8000-001",
 "61001-3500-001",
 "61001-5700-010",
 "61001-22100-001",
 "61001-12600-001",
 "61001-8900-001",
 "61001-6800-002",
 "61001-9000-001",
 "61001-11500-004",
 "61001-22500-064",
 "61001-14700-001",
 "61001-9300-001",
 "61001-6300-001",
 "61001-5800-001",
 "61001-20600-001",
 "61001-24900-001",
 "61001-3400-001",
 "61001-10700-001",
 "61001-11200-001",
 "61001-9200-001",
 "61001-12500-001",
 "61001-12900-001",
 "61001-9800-001",
 "61001-10800-001",
 "61001-23400-001",
 "61013-11300-001",
 "61013-8400-001",
 "61001-11600-031",
 "61001-12000-001",
 "61101-2700-001",
 "61101-8400-001",
 "61101-22500-008",
 "61101-23900-001",
 "61101-28000-001",
 "61101-8000-001",
 "61101-26800-001",
 "61101-12000-001",
 "61001-8200-002",
 "61001-11900-001",
 "61001-7700-001",
 "61001-3300-039",
 "61001-18700-001",
 "61001-5900-001",
 "61001-2900-001",
 "61001-1300-011",
 "61001-9100-003",
 "61001-14100-001",
 "61001-6400-001",
 "61001-5500-001",
 "61001-4400-001",
 "61001-11000-014",
 "61001-8800-002",
 "61001-8000-001",
 "61001-3500-001",
 "61001-5700-010",
 "61001-22100-001",
 "61001-12600-001",
 "61001-8900-001",
 "61001-6800-002",
 "61001-9000-001",
 "61001-11500-004",
 "61001-22500-064",
 "61001-14700-001",
 "61001-9300-001",
 "61001-6300-001",
 "61001-5800-001",
 "61001-20600-001",
 "61001-24900-001",
 "61001-3400-001",
 "61001-10700-001",
 "61001-11200-001",
 "61001-9200-001",
 "61001-12500-001",
 "61001-12900-001",
 "61001-9800-001",
 "61001-10800-001",
 "61001-23400-001",
 "61013-11300-001",
 "61013-8400-001",
 "61001-11600-031",
 "61001-12000-001",
 "61101-2700-001",
 "61101-8400-001",
 "61101-22500-008",
 "61101-23900-001",
 "61101-28000-001",
 "61101-8000-001",
 "61101-26800-001",
 "61101-12000-001",
 "61101-18700-001",
 "61101-20600-001",
 "61101-9200-001",
 "61101-11200-001",
 "61101-12900-001",
 "61101-12500-001",
 "61101-10800-001",
 "61101-23400-001",
 "61101-11300-001",
 "61109-8800-042"]