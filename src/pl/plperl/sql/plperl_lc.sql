--
-- Make sure strings are validated
-- Should fail for all encodings, as nul bytes are never permitted.
--
CREATE OR REPLACE FUNCTION perl_zerob() RETURNS TEXT AS $$
  return "abcd\0efg";
$$ LANGUAGE plperl;
SELECT perl_zerob();
CREATE OR REPLACE FUNCTION perl_0x80_in(text) RETURNS BOOL AS $$
  return ($_[0] eq "abc\x80de" ? "true" : "false");
$$ LANGUAGE plperl;
SELECT perl_0x80_in(E'abc\x80de');
CREATE OR REPLACE FUNCTION perl_0x80_out() RETURNS TEXT AS $$
  return "abc\x80de";
$$ LANGUAGE plperl;
SELECT perl_0x80_out() = E'abc\x80de';
CREATE OR REPLACE FUNCTION perl_utf_inout(text) RETURNS TEXT AS $$
  $str = $_[0]; $code = "NotUTF8:"; $match = "ab\xe5\xb1\xb1cd";
  if (utf8::is_utf8($str)) {
    $code = "UTF8:"; utf8::decode($str); $match="ab\x{5c71}cd";
  }
  return ($str ne $match ? $code."DIFFER" : $code."ab\x{5ddd}cd");
$$ LANGUAGE plperl;
SELECT encode(perl_utf_inout(E'ab\xe5\xb1\xb1cd')::bytea, 'escape')
