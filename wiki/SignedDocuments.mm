Some applications may want to add digital signatures to documents in a database, for integrity checking, identification or validation. For example, a validator function could refuse to allow a signed document to be replaced by one that wasn't signed by the same principal.

== A Proposal For Storing Signatures In JSON ==

As far as I (JensAlfke) know, there is no widely used schema for representing digital signatures in JSON. To get the ball rolling I'll propose one here. This is a translation of [[http://mooseyard.com/Jens/2008/04/cloudy-identity/|an existing YAML-based schema]] I've been using in an as-yet-unfinished app, which was in turn inspired by the earlier protocols SDSI and SPKI.

Here's an example to show what it looks like:

{{{
  "signature": {
    "signed": "oVCuVVlXPEdRPR+gy1k/UNOXtwvcN7LNpK6xTcA/hmlKh6uIT56E19LxWzA7POxmnhc351NVdoKC9XaUVsaZYDOnp2wWEWLUtdYYA8I++NZZIVlCHOjHCHr7mcfNcceDv+15RE9vguQ/PO1yaOU4DlviYt75y7xKMRs5REbZss6E/mr+0r1KE+f73dpHCVoDSW0azTD43pug2Pyh2Kar0GHXQcS4Iq/Y2nRFv7wyLUUmyVA7XI665a8QjMCiec2w0PqQ32FwGBYkH/iR/cfmaKjuwjAbW/qo7NoTH6WSFQy2ua/PVQs9B+dyjnZ5Z30Ernl9UTCVwjUmCc8J4hoaTQ==",
    "digest": "pFCzUK7yuO0dWtm0oATB7ag6vj0=",
    "date": "2008-04-15 21:55:46.830 -07:00",
    "expires": 21600,
    "signer": {
      "nickname": "snej",
      "publicKey": {
        "algorithm": "RSA",
        "bits": 2048,
        "data": "MIIBCgKCAQEApP6/D5aZm7nYfGwSMD3xQCCWw+XeU1NmZE7N/7eHvQlCUHMS8AacWh+s/PlPd1o7k+YePhoHnc1vR9uAfWm8iowiUU0RluUNxY0dRkTauRqeYM6//s+5ZXuh27pDDq2BgQYPL6EOp2UtWSQ/ojQjqX2/sGMkZ3k+uYiu1ZGQS2s0xTHPkgtuVI+Kg2TBY/28zAG4H/seUHNAP+frlpX+fizSC2oYNdREpEcVcVacHMQGwrj3mAr7g/LpJTnWgZhiJYvp7c4MkAYfHOIbKIXeXrF8oOz0EwgwSp0ZWkezuIYa4BMAns52WYK3LooQ+GttPIdVhSzzhLlY3psLeOf6nQIDAQAB"
      }
    }
  }
}
}}}

Yes, this is incomplete JSON. It shows only the `signature` key and value at the end of a larger JSON object. The structure shown here is the signature of the object containing it; this results in a single self-contained signed object, very handy for a CouchDB document.

The fields of `signature` are:

 * `signed`: The digital signature itself (the output of the RSA algorithm, in this example), encoded in base64.
 * `digest`: A SHA-1 digest of the data being signed, also encoded in base64.
 * `date`: The time the signature was generated.
 * `expires`: The number of seconds the signature remains valid after being generated.
 * `signer`: A nested object describing the "identity" (aka "principal" or "signer") that generated the signature:
   * `nickname`: A brief human-readable name for this identity. It can't be trusted to mean anything or be unique; it’s just a convenience for use when inspecting the signature, or for using as a default display-name in a UI.
   * `publicKey`: The actual public key that uniquely identifies the signer. It's composed of sub-fields: `algorithm` identifies the type of key, `bits` is the number of bits in the key, and `data` is the base64-encoded key data itself.

== Generating and Checking Digests ==

The tricky bit I glossed over is how to generate the `digest`. To do this we take a stream of bytes and run it through an algorithm like SHA-1. What's the stream of bytes? The JSON of the document, of course. But that's not including the nested `signature` object, since the digest is generated ''before'' the signature. So anyone validating the signature has to strip the `signature` block out of the document first. And since the CouchDB server may add metadata to the already-signed document when the creator uploads it, top-level keys prefixed with "_" should also be ignored.

So the process of verifying the digest looks like this:

 1. Remove the `signature` property from the document.
 1. Remove all other properties whose keys begin with "_".
 1. Serialize the result as canonical JSON (q.v.)
 1. Compute a SHA-1 digest of the resulting byte stream.
 1. Compare this with `signature.digest`.

If the digest is valid, the digital signature itself is verified using a similar technique:

 1. Start with the `signature` object.
 1. Remove the `signed` property.
 1. Serialize the result as canonical JSON (q.v.)
 1. Perform digital-signature verification on the resulting byte stream, using the `signed` field and the public key.

Note that the key does not directly sign the document. This is so that the signature can also encompass metadata like the creation and expiration dates. Also, it would be feasible to separate the signature from the document entirely, and store it elsewhere, since its `digest` field uniquely identifies the document it signs.

=== Processing JSON for Signing ===

A single object can be represented by multiple different JSON strings, with different sequences of bytes, since key/value pairs may be rearranged, whitespace added or removed, and different Unicode encodings used. It's possible for the byte representation to change in transit, if the document is parsed into a data structure and then re-serialized. This would prevent the recipient from being able to verify the signature.

The signature has to be generated from a ''repeatable representation'' of the JSON. The important aspect is that the algorithm which generates the signing artifact can be generated reliably and repeatedly from the transferred text. It may be best to link to the algorithm which generates the signing artifact, or otherwise include the algorithm in the signature itself, so that the signature can be verified across time and space.

There is no standard for this yet, but [[http://www.unicode.org/reports/tr15/|the OLPC group has documented one]] that's pretty reasonable:

 * No whitespace.
 * No escape sequences in strings other than `\"` and `\\`. All other characters must be represented literally, including control characters.
 * No trailing commas.
 * Object keys sorted by Unicode character values (code points). The sorting occurs ''before'' escape sequences are added.
 * No decimal points in numbers (i.e. only integers allowed) or leading zeros. "-0" is not allowed.
 * UTF-8 encoding of Unicode Normalization Form C

Note: The OLPC spec allows arbitrary byte sequences in strings, for easy storage of binary data. But this contradicts the [[http://www.ietf.org/rfc/rfc4627.txt|JSON specification]], which clearly states that "a string is a  sequence of zero or more Unicode characters".

== A Digression On Identities ==

This mechanism considers a signer to be identical to his/her/its public key. In other words, there is no additional form of identification such as a URL or Social Security Number. This is sometimes called "key-centric identity", and it seems pretty weird if you're not used to it, but actually works very well. Assigning a human-meaningful identity turns out to be intractably difficult, for reasons that are as much social as technological. (In a nutshell: there is no single form of identification that will be meaningful to all the people you might want to identify yourself to; and the more forms of identification you provide, the more privacy you lose.) I've written about this at greater length [[http://mooseyard.com/Jens/2007/12/facebook-and-decentralized-identifiers/|elsewhere]].

What you ''do'' get from key-centric identity is confidence that, if two documents were signed by the same public key, then they were signed by the same person (or other entity with access to the private key.) That's pretty useful in itself, e.g. for the example CouchDB validation function I mentioned at the beginning. And if you can then, through unspecified other means, convince yourself that a particular person known to you owns that private key, then you know the human identity of the signer of those documents.

It's perfectly possible to build more traditional types of certificates, with hierarchies of Certificate Authorities, out of these signatures. They're expressed just as they are in X.509, with the same kind of topology of nested signatures; it's just that the syntax is infinitely easier to understand in JSON :)
