/*
Implementation by the Keccak, Keyak and Ketje Teams, namely, Guido Bertoni,
Joan Daemen, Michaël Peeters, Gilles Van Assche and Ronny Van Keer, hereby
denoted as "the implementer".

For more information, feedback or questions, please refer to our websites:
http://keccak.noekeon.org/
http://keyak.noekeon.org/
http://ketje.noekeon.org/

To the extent possible under law, the implementer has waived all copyright
and related or neighboring rights to the source code in this file.
http://creativecommons.org/publicdomain/zero/1.0/
*/

#include "test_crypto_aead.h"

int main()
{
    const unsigned char *key = (const unsigned char *)
        "\x5a\x4b\x3c\x2d\x1e\x0f\x00\xf1\xe2\xd3\xc4\xb5\xa6\x97\x88\x79";
    const unsigned char *nonce = (const unsigned char *)
        "\x6b\x4c\x2d\x0e\xef\xd0\xb1\x92\x72\x53\x34\x15\xf6\xd7\xb8\x99";
    const unsigned char *AD = (const unsigned char *)
        "\x32\xf3\xb4\x75\x35\xf6";
    const unsigned char *plaintext = (const unsigned char *)
        "\xe4\x65\xe5\x66\xe6\x67\xe7";
    const unsigned char *ciphertext = (const unsigned char *)
        "\x7b\x13\x13\x73\xb4\xda\x8d\x65\x05\xf1\xbd\xde\x54\xb8\xa3\x87\xca\x09\xe6\xfd\xff\x4d\xaa";
    return test_crypto_aead(key, 16, nonce, 16, AD, 6, plaintext, 7, ciphertext, 16);
}
