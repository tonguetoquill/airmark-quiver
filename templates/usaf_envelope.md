~~~
$quill: usaf_envelope@0.0
$kind: main
return:
  lines:
    - ORG/SYMBOL
    - 123 STREET AVE
    - CITY ST 12345-6789
  official_business: true
delivery:
  attention: RANK FIRST M LAST
  recipient: ORG/SYMBOL
  street: 123 STREET AVE
  city: CITY ST 12345-6789
envelope:
  size: number-10
$ext:
  editor:
    tips:
      - Addresses print in capitals. Leave out punctuation except the slash in an office symbol and the dash in a ZIP+4.
      - The street and a post office box never share a line. An APO or FPO line carries no city beside it.
      - OFFICIAL BUSINESS prints two lines under the return address. Turn it off when the mail is not official.
      - Turn on Non-machineable when the sealed envelope is thicker than 1/4 inch.
~~~
