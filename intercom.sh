887dcd1d689f1451c4f4bf63c7e6c4c243c071be



curl https://api.intercom.io/companies \
-X POST \
-H 'Authorization:Bearer dG9rOmQyYjgwMGY3Xzc2MTJfNDdjN19hOWU3X2I0M2ExMzkyMjdhYzoxOjA' \
-H 'Accept: application/json' \
-H 'Content-Type:application/json' -d '
{
  "company_id": "10332",
  "custom_attributes": {
    "website_key" : "1_iS4mJ0SX4d88Lm1Q_0WACxYGyAPOkiX8Rutd_IcCYs"
  }
}'



curl https://api.intercom.io/companies \
-X PUT \
-H 'Authorization:Bearer <access_token>' \
-H 'Accept: application/json' \
-H 'Content-Type:application/json' -d '
{
  "company_id": "10332",
  "custom_attributes": {
    "website_key" : "1_iS4mJ0SX4d88Lm1Q_0WACxYGyAPOkiX8Rutd_IcCYs"
  }
}'