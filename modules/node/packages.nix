# This file has been generated by node2nix 1.11.1. Do not edit!

{ nodeEnv, fetchurl, fetchgit, nix-gitignore, stdenv, lib, globalBuildInputs ? [ ] }:

let
  sources = {
    "@cspotcode/source-map-support-0.8.1" = {
      name = "_at_cspotcode_slash_source-map-support";
      packageName = "@cspotcode/source-map-support";
      version = "0.8.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/@cspotcode/source-map-support/-/source-map-support-0.8.1.tgz";
        sha512 = "IchNf6dN4tHoMFIn/7OE8LWZ19Y6q/67Bmf6vnGREv8RSbBVb9LPJxEcnwrcwX6ixSvaiGoomAUvu4YSxXrVgw==";
      };
    };
    "@jridgewell/resolve-uri-3.1.2" = {
      name = "_at_jridgewell_slash_resolve-uri";
      packageName = "@jridgewell/resolve-uri";
      version = "3.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/@jridgewell/resolve-uri/-/resolve-uri-3.1.2.tgz";
        sha512 = "bRISgCIjP20/tbWSPWMEi54QVPRZExkuD9lJL+UIxUKtwVJA8wW1Trb1jMs1RFXo1CBTNZ/5hpC9QvmKWdopKw==";
      };
    };
    "@jridgewell/sourcemap-codec-1.5.0" = {
      name = "_at_jridgewell_slash_sourcemap-codec";
      packageName = "@jridgewell/sourcemap-codec";
      version = "1.5.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/@jridgewell/sourcemap-codec/-/sourcemap-codec-1.5.0.tgz";
        sha512 = "gv3ZRaISU3fjPAgNsriBRqGWQL6quFx04YMPW/zD8XMLsU32mhCCbfbO6KZFLjvYpCZ8zyDEgqsgf+PwPaM7GQ==";
      };
    };
    "@jridgewell/trace-mapping-0.3.9" = {
      name = "_at_jridgewell_slash_trace-mapping";
      packageName = "@jridgewell/trace-mapping";
      version = "0.3.9";
      src = fetchurl {
        url = "https://registry.npmjs.org/@jridgewell/trace-mapping/-/trace-mapping-0.3.9.tgz";
        sha512 = "3Belt6tdc8bPgAtbcmdtNJlirVoTmEb5e2gC94PnkwEW9jI6CAHUeoG85tjWP5WquqfavoMtMwiG4P926ZKKuQ==";
      };
    };
    "@swc/core-1.10.0" = {
      name = "_at_swc_slash_core";
      packageName = "@swc/core";
      version = "1.10.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/@swc/core/-/core-1.10.0.tgz";
        sha512 = "+CuuTCmQFfzaNGg1JmcZvdUVITQXJk9sMnl1C2TiDLzOSVOJRwVD4dNo5dljX/qxpMAN+2BIYlwjlSkoGi6grg==";
      };
    };
    "@swc/counter-0.1.3" = {
      name = "_at_swc_slash_counter";
      packageName = "@swc/counter";
      version = "0.1.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/@swc/counter/-/counter-0.1.3.tgz";
        sha512 = "e2BR4lsJkkRlKZ/qCHPw9ZaSxc0MVUd7gtbtaB7aMvHeJVYe8sOB8DBZkP2DtISHGSku9sCK6T6cnY0CtXrOCQ==";
      };
    };
    "@swc/helpers-0.5.15" = {
      name = "_at_swc_slash_helpers";
      packageName = "@swc/helpers";
      version = "0.5.15";
      src = fetchurl {
        url = "https://registry.npmjs.org/@swc/helpers/-/helpers-0.5.15.tgz";
        sha512 = "JQ5TuMi45Owi4/BIMAJBoSQoOJu12oOk/gADqlcUL9JEdHB8vyjUSsxqeNXnmXHjYKMi2WcYtezGEEhqUI/E2g==";
      };
    };
    "@swc/types-0.1.17" = {
      name = "_at_swc_slash_types";
      packageName = "@swc/types";
      version = "0.1.17";
      src = fetchurl {
        url = "https://registry.npmjs.org/@swc/types/-/types-0.1.17.tgz";
        sha512 = "V5gRru+aD8YVyCOMAjMpWR1Ui577DD5KSJsHP8RAxopAH22jFz6GZd/qxqjO6MJHQhcsjvjOFXyDhyLQUnMveQ==";
      };
    };
    "@swc/wasm-1.10.0" = {
      name = "_at_swc_slash_wasm";
      packageName = "@swc/wasm";
      version = "1.10.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/@swc/wasm/-/wasm-1.10.0.tgz";
        sha512 = "R6zb7Vd8FxW3kSVVSR154f7Bsxv+lEMNVipgeoSESITbqngqtl9HAgKpdDV/DAK960iFxmbDyvgu2+GPrMeLzQ==";
      };
    };
    "@tsconfig/node10-1.0.11" = {
      name = "_at_tsconfig_slash_node10";
      packageName = "@tsconfig/node10";
      version = "1.0.11";
      src = fetchurl {
        url = "https://registry.npmjs.org/@tsconfig/node10/-/node10-1.0.11.tgz";
        sha512 = "DcRjDCujK/kCk/cUe8Xz8ZSpm8mS3mNNpta+jGCA6USEDfktlNvm1+IuZ9eTcDbNk41BHwpHHeW+N1lKCz4zOw==";
      };
    };
    "@tsconfig/node12-1.0.11" = {
      name = "_at_tsconfig_slash_node12";
      packageName = "@tsconfig/node12";
      version = "1.0.11";
      src = fetchurl {
        url = "https://registry.npmjs.org/@tsconfig/node12/-/node12-1.0.11.tgz";
        sha512 = "cqefuRsh12pWyGsIoBKJA9luFu3mRxCA+ORZvA4ktLSzIuCUtWVxGIuXigEwO5/ywWFMZ2QEGKWvkZG1zDMTag==";
      };
    };
    "@tsconfig/node14-1.0.3" = {
      name = "_at_tsconfig_slash_node14";
      packageName = "@tsconfig/node14";
      version = "1.0.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/@tsconfig/node14/-/node14-1.0.3.tgz";
        sha512 = "ysT8mhdixWK6Hw3i1V2AeRqZ5WfXg1G43mqoYlM2nc6388Fq5jcXyr5mRsqViLx/GJYdoL0bfXD8nmF+Zn/Iow==";
      };
    };
    "@tsconfig/node16-1.0.4" = {
      name = "_at_tsconfig_slash_node16";
      packageName = "@tsconfig/node16";
      version = "1.0.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/@tsconfig/node16/-/node16-1.0.4.tgz";
        sha512 = "vxhUy4J8lyeyinH7Azl1pdd43GJhZH/tP2weN8TntQblOY+A0XbT8DJk1/oCPuOOyg/Ja757rG0CgHcWC8OfMA==";
      };
    };
    "@types/node-22.10.1" = {
      name = "_at_types_slash_node";
      packageName = "@types/node";
      version = "22.10.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/@types/node/-/node-22.10.1.tgz";
        sha512 = "qKgsUwfHZV2WCWLAnVP1JqnpE6Im6h3Y0+fYgMTasNQ7V++CBX5OT1as0g0f+OyubbFqhf6XVNIsmN4IIhEgGQ==";
      };
    };
    "acorn-8.14.0" = {
      name = "acorn";
      packageName = "acorn";
      version = "8.14.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/acorn/-/acorn-8.14.0.tgz";
        sha512 = "cl669nCJTZBsL97OF4kUQm5g5hC2uihk0NxY3WENAC0TYdILVkAyHymAntgxGkl7K+t0cXIrH5siy5S4XkFycA==";
      };
    };
    "acorn-walk-8.3.4" = {
      name = "acorn-walk";
      packageName = "acorn-walk";
      version = "8.3.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/acorn-walk/-/acorn-walk-8.3.4.tgz";
        sha512 = "ueEepnujpqee2o5aIYnvHU6C0A42MNdsIDeqy5BydrkuC5R1ZuUFnm27EeFJGoEHJQgn3uleRvmTXaJgfXbt4g==";
      };
    };
    "ansi-styles-4.3.0" = {
      name = "ansi-styles";
      packageName = "ansi-styles";
      version = "4.3.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/ansi-styles/-/ansi-styles-4.3.0.tgz";
        sha512 = "zbB9rCJAT1rbjiVDb2hqKFHNYLxgtk8NURxZ3IZwD3F6NtxbXZQCnnSi1Lkx+IDohdPlFp222wVALIheZJQSEg==";
      };
    };
    "arg-4.1.3" = {
      name = "arg";
      packageName = "arg";
      version = "4.1.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/arg/-/arg-4.1.3.tgz";
        sha512 = "58S9QDqG0Xx27YwPSt9fJxivjYl432YCwfDMfZ+71RAqUrZef7LrKQZ3LHLOwCS4FLNBplP533Zx895SeOCHvA==";
      };
    };
    "async-2.6.4" = {
      name = "async";
      packageName = "async";
      version = "2.6.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/async/-/async-2.6.4.tgz";
        sha512 = "mzo5dfJYwAn29PeiJ0zvwTo04zj8HDJj0Mn8TD7sno7q12prdbnasKJHhkm2c1LgrhlJ0teaea8860oxi51mGA==";
      };
    };
    "basic-auth-2.0.1" = {
      name = "basic-auth";
      packageName = "basic-auth";
      version = "2.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/basic-auth/-/basic-auth-2.0.1.tgz";
        sha512 = "NF+epuEdnUYVlGuhaxbbq+dvJttwLnGY+YixlXlME5KpQ5W3CnXA5cVTneY3SPbPDRkcjMbifrwmFYcClgOZeg==";
      };
    };
    "call-bind-1.0.7" = {
      name = "call-bind";
      packageName = "call-bind";
      version = "1.0.7";
      src = fetchurl {
        url = "https://registry.npmjs.org/call-bind/-/call-bind-1.0.7.tgz";
        sha512 = "GHTSNSYICQ7scH7sZ+M2rFopRoLh8t2bLSW6BbgrtLsahOIB5iyAVJf9GjWK3cYTDaMj4XdBpM1cA6pIS0Kv2w==";
      };
    };
    "chalk-4.1.2" = {
      name = "chalk";
      packageName = "chalk";
      version = "4.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/chalk/-/chalk-4.1.2.tgz";
        sha512 = "oKnbhFyRIXpUuez8iBMmyEa4nbj4IOQyuhc/wy9kY7/WVPcwIO9VA668Pu8RkO7+0G76SLROeyw9CpQ061i4mA==";
      };
    };
    "color-convert-2.0.1" = {
      name = "color-convert";
      packageName = "color-convert";
      version = "2.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/color-convert/-/color-convert-2.0.1.tgz";
        sha512 = "RRECPsj7iu/xb5oKYcsFHSppFNnsj/52OVTRKb4zP5onXwVF3zVmmToNcOfGC+CRDpfK/U584fMg38ZHCaElKQ==";
      };
    };
    "color-name-1.1.4" = {
      name = "color-name";
      packageName = "color-name";
      version = "1.1.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/color-name/-/color-name-1.1.4.tgz";
        sha512 = "dOy+3AuW3a2wNbZHIuMZpTcgjGuLU/uBL/ubcZF9OXbDo8ff4O8yVp5Bf0efS8uEoYo5q4Fx7dY9OgQGXgAsQA==";
      };
    };
    "corser-2.0.1" = {
      name = "corser";
      packageName = "corser";
      version = "2.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/corser/-/corser-2.0.1.tgz";
        sha512 = "utCYNzRSQIZNPIcGZdQc92UVJYAhtGAteCFg0yRaFm8f0P+CPtyGyHXJcGXnffjCybUCEx3FQ2G7U3/o9eIkVQ==";
      };
    };
    "create-require-1.1.1" = {
      name = "create-require";
      packageName = "create-require";
      version = "1.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/create-require/-/create-require-1.1.1.tgz";
        sha512 = "dcKFX3jn0MpIaXjisoRvexIJVEKzaq7z2rZKxf+MSr9TkdmHmsU4m2lcLojrj/FHl8mk5VxMmYA+ftRkP/3oKQ==";
      };
    };
    "debug-3.2.7" = {
      name = "debug";
      packageName = "debug";
      version = "3.2.7";
      src = fetchurl {
        url = "https://registry.npmjs.org/debug/-/debug-3.2.7.tgz";
        sha512 = "CFjzYYAi4ThfiQvizrFQevTTXHtnCqWfe7x1AhgEscTz6ZbLbfoLRLPugTQyBth6f8ZERVUSyWHFD/7Wu4t1XQ==";
      };
    };
    "define-data-property-1.1.4" = {
      name = "define-data-property";
      packageName = "define-data-property";
      version = "1.1.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/define-data-property/-/define-data-property-1.1.4.tgz";
        sha512 = "rBMvIzlpA8v6E+SJZoo++HAYqsLrkg7MSfIinMPFhmkorw7X+dOXVJQs+QT69zGkzMyfDnIMN2Wid1+NbL3T+A==";
      };
    };
    "detect-indent-7.0.1" = {
      name = "detect-indent";
      packageName = "detect-indent";
      version = "7.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/detect-indent/-/detect-indent-7.0.1.tgz";
        sha512 = "Mc7QhQ8s+cLrnUfU/Ji94vG/r8M26m8f++vyres4ZoojaRDpZ1eSIh/EpzLNwlWuvzSZ3UbDFspjFvTDXe6e/g==";
      };
    };
    "detect-newline-4.0.1" = {
      name = "detect-newline";
      packageName = "detect-newline";
      version = "4.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/detect-newline/-/detect-newline-4.0.1.tgz";
        sha512 = "qE3Veg1YXzGHQhlA6jzebZN2qVf6NX+A7m7qlhCGG30dJixrAQhYOsJjsnBjJkCSmuOPpCk30145fr8FV0bzog==";
      };
    };
    "diff-4.0.2" = {
      name = "diff";
      packageName = "diff";
      version = "4.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/diff/-/diff-4.0.2.tgz";
        sha512 = "58lmxKSA4BNyLz+HHMUzlOEpg09FV+ev6ZMe3vJihgdxzgcwZ8VoEEPmALCZG9LmqfVoNMMKpttIYTVG6uDY7A==";
      };
    };
    "es-define-property-1.0.0" = {
      name = "es-define-property";
      packageName = "es-define-property";
      version = "1.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/es-define-property/-/es-define-property-1.0.0.tgz";
        sha512 = "jxayLKShrEqqzJ0eumQbVhTYQM27CfT1T35+gCgDFoL82JLsXqTJ76zv6A0YLOgEnLUMvLzsDsGIrl8NFpT2gQ==";
      };
    };
    "es-errors-1.3.0" = {
      name = "es-errors";
      packageName = "es-errors";
      version = "1.3.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/es-errors/-/es-errors-1.3.0.tgz";
        sha512 = "Zf5H2Kxt2xjTvbJvP2ZWLEICxA6j+hAmMzIlypy4xcBg1vKVnx89Wy0GbS+kf5cwCVFFzdCFh2XSCFNULS6csw==";
      };
    };
    "eventemitter3-4.0.7" = {
      name = "eventemitter3";
      packageName = "eventemitter3";
      version = "4.0.7";
      src = fetchurl {
        url = "https://registry.npmjs.org/eventemitter3/-/eventemitter3-4.0.7.tgz";
        sha512 = "8guHBZCwKnFhYdHr2ysuRWErTwhoN2X8XELRlrRwpmfeY2jjuUN4taQMsULKUVo1K4DvZl+0pgfyoysHxvmvEw==";
      };
    };
    "fdir-6.4.2" = {
      name = "fdir";
      packageName = "fdir";
      version = "6.4.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/fdir/-/fdir-6.4.2.tgz";
        sha512 = "KnhMXsKSPZlAhp7+IjUkRZKPb4fUyccpDrdFXbi4QL1qkmFh9kVY09Yox+n4MaOb3lHZ1Tv829C3oaaXoMYPDQ==";
      };
    };
    "follow-redirects-1.15.9" = {
      name = "follow-redirects";
      packageName = "follow-redirects";
      version = "1.15.9";
      src = fetchurl {
        url = "https://registry.npmjs.org/follow-redirects/-/follow-redirects-1.15.9.tgz";
        sha512 = "gew4GsXizNgdoRyqmyfMHyAmXsZDk6mHkSxZFCzW9gwlbtOW44CDtYavM+y+72qD/Vq2l550kMF52DT8fOLJqQ==";
      };
    };
    "function-bind-1.1.2" = {
      name = "function-bind";
      packageName = "function-bind";
      version = "1.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/function-bind/-/function-bind-1.1.2.tgz";
        sha512 = "7XHNxH7qX9xG5mIwxkhumTox/MIRNcOgDrxWsMt2pAr23WHp6MrRlN7FBSFpCpr+oVO0F744iUgR82nJMfG2SA==";
      };
    };
    "get-intrinsic-1.2.4" = {
      name = "get-intrinsic";
      packageName = "get-intrinsic";
      version = "1.2.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/get-intrinsic/-/get-intrinsic-1.2.4.tgz";
        sha512 = "5uYhsJH8VJBTv7oslg4BznJYhDoRI6waYCxMmCdnTrcCrHA/fCFKoTFz2JKKE0HdDFUF7/oQuhzumXJK7paBRQ==";
      };
    };
    "get-stdin-9.0.0" = {
      name = "get-stdin";
      packageName = "get-stdin";
      version = "9.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/get-stdin/-/get-stdin-9.0.0.tgz";
        sha512 = "dVKBjfWisLAicarI2Sf+JuBE/DghV4UzNAVe9yhEJuzeREd3JhOTE9cUaJTeSa77fsbQUK3pcOpJfM59+VKZaA==";
      };
    };
    "git-hooks-list-3.1.0" = {
      name = "git-hooks-list";
      packageName = "git-hooks-list";
      version = "3.1.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/git-hooks-list/-/git-hooks-list-3.1.0.tgz";
        sha512 = "LF8VeHeR7v+wAbXqfgRlTSX/1BJR9Q1vEMR8JAz1cEg6GX07+zyj3sAdDvYjj/xnlIfVuGgj4qBei1K3hKH+PA==";
      };
    };
    "gopd-1.2.0" = {
      name = "gopd";
      packageName = "gopd";
      version = "1.2.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/gopd/-/gopd-1.2.0.tgz";
        sha512 = "ZUKRh6/kUFoAiTAtTYPZJ3hw9wNxx+BIBOijnlG9PnrJsCcSjs1wyyD6vJpaYtgnzDrKYRSqf3OO6Rfa93xsRg==";
      };
    };
    "has-flag-4.0.0" = {
      name = "has-flag";
      packageName = "has-flag";
      version = "4.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/has-flag/-/has-flag-4.0.0.tgz";
        sha512 = "EykJT/Q1KjTWctppgIAgfSO0tKVuZUjhgMr17kqTumMl6Afv3EISleU7qZUzoXDFTAHTDC4NOoG/ZxU3EvlMPQ==";
      };
    };
    "has-property-descriptors-1.0.2" = {
      name = "has-property-descriptors";
      packageName = "has-property-descriptors";
      version = "1.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/has-property-descriptors/-/has-property-descriptors-1.0.2.tgz";
        sha512 = "55JNKuIW+vq4Ke1BjOTjM2YctQIvCT7GFzHwmfZPGo5wnrgkid0YQtnAleFSqumZm4az3n2BS+erby5ipJdgrg==";
      };
    };
    "has-proto-1.1.0" = {
      name = "has-proto";
      packageName = "has-proto";
      version = "1.1.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/has-proto/-/has-proto-1.1.0.tgz";
        sha512 = "QLdzI9IIO1Jg7f9GT1gXpPpXArAn6cS31R1eEZqz08Gc+uQ8/XiqHWt17Fiw+2p6oTTIq5GXEpQkAlA88YRl/Q==";
      };
    };
    "has-symbols-1.1.0" = {
      name = "has-symbols";
      packageName = "has-symbols";
      version = "1.1.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/has-symbols/-/has-symbols-1.1.0.tgz";
        sha512 = "1cDNdwJ2Jaohmb3sg4OmKaMBwuC48sYni5HUw2DvsC8LjGTLK9h+eb1X6RyuOHe4hT0ULCW68iomhjUoKUqlPQ==";
      };
    };
    "hasown-2.0.2" = {
      name = "hasown";
      packageName = "hasown";
      version = "2.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/hasown/-/hasown-2.0.2.tgz";
        sha512 = "0hJU9SCPvmMzIBdZFqNPXWa6dqh7WdH0cII9y+CyS8rG3nL48Bclra9HmKhVVUHyPWNH5Y7xDwAB7bfgSjkUMQ==";
      };
    };
    "he-1.2.0" = {
      name = "he";
      packageName = "he";
      version = "1.2.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/he/-/he-1.2.0.tgz";
        sha512 = "F/1DnUGPopORZi0ni+CvrCgHQ5FyEAHRLSApuYWMmrbSwoN2Mn/7k+Gl38gJnR7yyDZk6WLXwiGod1JOWNDKGw==";
      };
    };
    "html-encoding-sniffer-3.0.0" = {
      name = "html-encoding-sniffer";
      packageName = "html-encoding-sniffer";
      version = "3.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/html-encoding-sniffer/-/html-encoding-sniffer-3.0.0.tgz";
        sha512 = "oWv4T4yJ52iKrufjnyZPkrN0CH3QnrUqdB6In1g5Fe1mia8GmF36gnfNySxoZtxD5+NmYw1EElVXiBk93UeskA==";
      };
    };
    "http-proxy-1.18.1" = {
      name = "http-proxy";
      packageName = "http-proxy";
      version = "1.18.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/http-proxy/-/http-proxy-1.18.1.tgz";
        sha512 = "7mz/721AbnJwIVbnaSv1Cz3Am0ZLT/UBwkC92VlxhXv/k/BBQfM2fXElQNC27BVGr0uwUpplYPQM9LnaBMR5NQ==";
      };
    };
    "iconv-lite-0.6.3" = {
      name = "iconv-lite";
      packageName = "iconv-lite";
      version = "0.6.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/iconv-lite/-/iconv-lite-0.6.3.tgz";
        sha512 = "4fCk79wshMdzMp2rH06qWrJE4iolqLhCUH+OiuIgU++RB0+94NlDL81atO7GX55uUKueo0txHNtvEyI6D7WdMw==";
      };
    };
    "is-plain-obj-4.1.0" = {
      name = "is-plain-obj";
      packageName = "is-plain-obj";
      version = "4.1.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/is-plain-obj/-/is-plain-obj-4.1.0.tgz";
        sha512 = "+Pgi+vMuUNkJyExiMBt5IlFoMyKnr5zhJ4Uspz58WOhBF5QoIZkFyNHIbBAtHwzVAgk5RtndVNsDRN61/mmDqg==";
      };
    };
    "lodash-4.17.21" = {
      name = "lodash";
      packageName = "lodash";
      version = "4.17.21";
      src = fetchurl {
        url = "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz";
        sha512 = "v2kDEe57lecTulaDIuNTPy3Ry4gLGJ6Z1O3vE1krgXZNrsQ+LFTGHVxVjcXPs17LhbZVGedAJv8XZ1tvj5FvSg==";
      };
    };
    "make-error-1.3.6" = {
      name = "make-error";
      packageName = "make-error";
      version = "1.3.6";
      src = fetchurl {
        url = "https://registry.npmjs.org/make-error/-/make-error-1.3.6.tgz";
        sha512 = "s8UhlNe7vPKomQhC1qFelMokr/Sc3AgNbso3n74mVPA5LTZwkB9NlXf4XPamLxJE8h0gh73rM94xvwRT2CVInw==";
      };
    };
    "mime-1.6.0" = {
      name = "mime";
      packageName = "mime";
      version = "1.6.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/mime/-/mime-1.6.0.tgz";
        sha512 = "x0Vn8spI+wuJ1O6S7gnbaQg8Pxh4NNHb7KSINmEWKiPE4RKOplvijn+NkmYmmRgP68mc70j2EbeTFRsrswaQeg==";
      };
    };
    "minimist-1.2.8" = {
      name = "minimist";
      packageName = "minimist";
      version = "1.2.8";
      src = fetchurl {
        url = "https://registry.npmjs.org/minimist/-/minimist-1.2.8.tgz";
        sha512 = "2yyAR8qBkN3YuheJanUpWC5U3bb5osDywNB8RzDVlDwDHbocAJveqqj1u8+SVD7jkWT4yvsHCpWqqWqAxb0zCA==";
      };
    };
    "mkdirp-0.5.6" = {
      name = "mkdirp";
      packageName = "mkdirp";
      version = "0.5.6";
      src = fetchurl {
        url = "https://registry.npmjs.org/mkdirp/-/mkdirp-0.5.6.tgz";
        sha512 = "FP+p8RB8OWpF3YZBCrP5gtADmtXApB5AMLn+vdyA+PyxCjrCs00mjyUozssO33cwDeT3wNGdLxJ5M//YqtHAJw==";
      };
    };
    "ms-2.1.3" = {
      name = "ms";
      packageName = "ms";
      version = "2.1.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/ms/-/ms-2.1.3.tgz";
        sha512 = "6FlzubTLZG3J2a/NVCAleEhjzq5oxgHyaCU9yYXvcLsvoVaHJq/s5xXI6/XXP6tz7R9xAOtHnSO/tXtF3WRTlA==";
      };
    };
    "object-inspect-1.13.3" = {
      name = "object-inspect";
      packageName = "object-inspect";
      version = "1.13.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/object-inspect/-/object-inspect-1.13.3.tgz";
        sha512 = "kDCGIbxkDSXE3euJZZXzc6to7fCrKHNI/hSRQnRuQ+BWjFNzZwiFF8fj/6o2t2G9/jTj8PSIYTfCLelLZEeRpA==";
      };
    };
    "opener-1.5.2" = {
      name = "opener";
      packageName = "opener";
      version = "1.5.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/opener/-/opener-1.5.2.tgz";
        sha512 = "ur5UIdyw5Y7yEj9wLzhqXiy6GZ3Mwx0yGI+5sMn2r0N0v3cKJvUmFH5yPP+WXh9e0xfyzyJX95D8l088DNFj7A==";
      };
    };
    "picomatch-4.0.2" = {
      name = "picomatch";
      packageName = "picomatch";
      version = "4.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/picomatch/-/picomatch-4.0.2.tgz";
        sha512 = "M7BAV6Rlcy5u+m6oPhAPFgJTzAioX/6B0DxyvDlo9l8+T3nLKbrczg2WLUyzd45L8RqfUMyGPzekbMvX2Ldkwg==";
      };
    };
    "portfinder-1.0.32" = {
      name = "portfinder";
      packageName = "portfinder";
      version = "1.0.32";
      src = fetchurl {
        url = "https://registry.npmjs.org/portfinder/-/portfinder-1.0.32.tgz";
        sha512 = "on2ZJVVDXRADWE6jnQaX0ioEylzgBpQk8r55NE4wjXW1ZxO+BgDlY6DXwj20i0V8eB4SenDQ00WEaxfiIQPcxg==";
      };
    };
    "qs-6.13.1" = {
      name = "qs";
      packageName = "qs";
      version = "6.13.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/qs/-/qs-6.13.1.tgz";
        sha512 = "EJPeIn0CYrGu+hli1xilKAPXODtJ12T0sP63Ijx2/khC2JtuaN3JyNIpvmnkmaEtha9ocbG4A4cMcr+TvqvwQg==";
      };
    };
    "requires-port-1.0.0" = {
      name = "requires-port";
      packageName = "requires-port";
      version = "1.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/requires-port/-/requires-port-1.0.0.tgz";
        sha512 = "KigOCHcocU3XODJxsu8i/j8T9tzT4adHiecwORRQ0ZZFcp7ahwXuRU1m+yuO90C5ZUyGeGfocHDI14M3L3yDAQ==";
      };
    };
    "safe-buffer-5.1.2" = {
      name = "safe-buffer";
      packageName = "safe-buffer";
      version = "5.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/safe-buffer/-/safe-buffer-5.1.2.tgz";
        sha512 = "Gd2UZBJDkXlY7GbJxfsE8/nvKkUEU1G38c1siN6QP6a9PT9MmHB8GnpscSmMJSoF8LOIrt8ud/wPtojys4G6+g==";
      };
    };
    "safer-buffer-2.1.2" = {
      name = "safer-buffer";
      packageName = "safer-buffer";
      version = "2.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/safer-buffer/-/safer-buffer-2.1.2.tgz";
        sha512 = "YZo3K82SD7Riyi0E1EQPojLz7kpepnSQI9IyPbHHg1XXXevb5dJI7tpyN2ADxGcQbHG7vcyRHk0cbwqcQriUtg==";
      };
    };
    "secure-compare-3.0.1" = {
      name = "secure-compare";
      packageName = "secure-compare";
      version = "3.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/secure-compare/-/secure-compare-3.0.1.tgz";
        sha512 = "AckIIV90rPDcBcglUwXPF3kg0P0qmPsPXAj6BBEENQE1p5yA1xfmDJzfi1Tappj37Pv2mVbKpL3Z1T+Nn7k1Qw==";
      };
    };
    "semver-7.6.3" = {
      name = "semver";
      packageName = "semver";
      version = "7.6.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/semver/-/semver-7.6.3.tgz";
        sha512 = "oVekP1cKtI+CTDvHWYFUcMtsK/00wmAEfyqKfNdARm8u1wNVhSgaX7A8d4UuIlUI5e84iEwOhs7ZPYRmzU9U6A==";
      };
    };
    "set-function-length-1.2.2" = {
      name = "set-function-length";
      packageName = "set-function-length";
      version = "1.2.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/set-function-length/-/set-function-length-1.2.2.tgz";
        sha512 = "pgRc4hJ4/sNjWCSS9AmnS40x3bNMDTknHgL5UaMBTMyJnU90EgWh1Rz+MC9eFu4BuN/UwZjKQuY/1v3rM7HMfg==";
      };
    };
    "side-channel-1.0.6" = {
      name = "side-channel";
      packageName = "side-channel";
      version = "1.0.6";
      src = fetchurl {
        url = "https://registry.npmjs.org/side-channel/-/side-channel-1.0.6.tgz";
        sha512 = "fDW/EZ6Q9RiO8eFG8Hj+7u/oW+XrPTIChwCOM2+th2A6OblDtYYIpve9m+KvI9Z4C9qSEXlaGR6bTEYHReuglA==";
      };
    };
    "sort-object-keys-1.1.3" = {
      name = "sort-object-keys";
      packageName = "sort-object-keys";
      version = "1.1.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/sort-object-keys/-/sort-object-keys-1.1.3.tgz";
        sha512 = "855pvK+VkU7PaKYPc+Jjnmt4EzejQHyhhF33q31qG8x7maDzkeFhAAThdCYay11CISO+qAMwjOBP+fPZe0IPyg==";
      };
    };
    "supports-color-7.2.0" = {
      name = "supports-color";
      packageName = "supports-color";
      version = "7.2.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/supports-color/-/supports-color-7.2.0.tgz";
        sha512 = "qpCAvRl9stuOHveKsn7HncJRvv501qIacKzQlO/+Lwxc9+0q2wLyv4Dfvt80/DPn2pqOBsJdDiogXGR9+OvwRw==";
      };
    };
    "tinyglobby-0.2.10" = {
      name = "tinyglobby";
      packageName = "tinyglobby";
      version = "0.2.10";
      src = fetchurl {
        url = "https://registry.npmjs.org/tinyglobby/-/tinyglobby-0.2.10.tgz";
        sha512 = "Zc+8eJlFMvgatPZTl6A9L/yht8QqdmUNtURHaKZLmKBE12hNPSrqNkUp2cs3M/UKmNVVAMFQYSjYIVHDjW5zew==";
      };
    };
    "tslib-2.8.1" = {
      name = "tslib";
      packageName = "tslib";
      version = "2.8.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/tslib/-/tslib-2.8.1.tgz";
        sha512 = "oJFu94HQb+KVduSUQL7wnpmqnfmLsOA/nAh6b6EH0wCEoK0/mPeXU6c3wKDV83MkOuHPRHtSXKKU99IBazS/2w==";
      };
    };
    "typescript-5.7.2" = {
      name = "typescript";
      packageName = "typescript";
      version = "5.7.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/typescript/-/typescript-5.7.2.tgz";
        sha512 = "i5t66RHxDvVN40HfDd1PsEThGNnlMCMT3jMUuoh9/0TaqWevNontacunWyN02LA9/fIbEWlcHZcgTKb9QoaLfg==";
      };
    };
    "undici-types-6.20.0" = {
      name = "undici-types";
      packageName = "undici-types";
      version = "6.20.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/undici-types/-/undici-types-6.20.0.tgz";
        sha512 = "Ny6QZ2Nju20vw1SRHe3d9jVu6gJ+4e3+MMpqu7pqE5HT6WsTSlce++GQmK5UXS8mzV8DSYHrQH+Xrf2jVcuKNg==";
      };
    };
    "union-0.5.0" = {
      name = "union";
      packageName = "union";
      version = "0.5.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/union/-/union-0.5.0.tgz";
        sha512 = "N6uOhuW6zO95P3Mel2I2zMsbsanvvtgn6jVqJv4vbVcz/JN0OkL9suomjQGmWtxJQXOCqUJvquc1sMeNz/IwlA==";
      };
    };
    "url-join-4.0.1" = {
      name = "url-join";
      packageName = "url-join";
      version = "4.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/url-join/-/url-join-4.0.1.tgz";
        sha512 = "jk1+QP6ZJqyOiuEI9AEWQfju/nB2Pw466kbA0LEZljHwKeMgd9WrAEgEGxjPDD2+TNbbb37rTyhEfrCXfuKXnA==";
      };
    };
    "v8-compile-cache-lib-3.0.1" = {
      name = "v8-compile-cache-lib";
      packageName = "v8-compile-cache-lib";
      version = "3.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/v8-compile-cache-lib/-/v8-compile-cache-lib-3.0.1.tgz";
        sha512 = "wa7YjyUGfNZngI/vtK0UHAN+lgDCxBPCylVXGp0zu59Fz5aiGtNXaq3DhIov063MorB+VfufLh3JlF2KdTK3xg==";
      };
    };
    "whatwg-encoding-2.0.0" = {
      name = "whatwg-encoding";
      packageName = "whatwg-encoding";
      version = "2.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/whatwg-encoding/-/whatwg-encoding-2.0.0.tgz";
        sha512 = "p41ogyeMUrw3jWclHWTQg1k05DSVXPLcVxRTYsXUk+ZooOCZLcoYgPZ/HL/D/N+uQPOtcp1me1WhBEaX02mhWg==";
      };
    };
    "yn-3.1.1" = {
      name = "yn";
      packageName = "yn";
      version = "3.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/yn/-/yn-3.1.1.tgz";
        sha512 = "Ux4ygGWsu2c7isFWe8Yu1YluJmqVhxqK2cLXNQA5AcC3QfbGNpM7fu0Y8b/z16pXLnFxZYvWhd3fhBY9DLmC6Q==";
      };
    };
  };
in
{
  http-server = nodeEnv.buildNodePackage {
    name = "http-server";
    packageName = "http-server";
    version = "14.1.1";
    src = fetchurl {
      url = "https://registry.npmjs.org/http-server/-/http-server-14.1.1.tgz";
      sha512 = "+cbxadF40UXd9T01zUHgA+rlo2Bg1Srer4+B4NwIHdaGxAGGv59nYRnGGDJ9LBk7alpS0US+J+bLLdQOOkJq4A==";
    };
    dependencies = [
      sources."ansi-styles-4.3.0"
      sources."async-2.6.4"
      sources."basic-auth-2.0.1"
      sources."call-bind-1.0.7"
      sources."chalk-4.1.2"
      sources."color-convert-2.0.1"
      sources."color-name-1.1.4"
      sources."corser-2.0.1"
      sources."debug-3.2.7"
      sources."define-data-property-1.1.4"
      sources."es-define-property-1.0.0"
      sources."es-errors-1.3.0"
      sources."eventemitter3-4.0.7"
      sources."follow-redirects-1.15.9"
      sources."function-bind-1.1.2"
      sources."get-intrinsic-1.2.4"
      sources."gopd-1.2.0"
      sources."has-flag-4.0.0"
      sources."has-property-descriptors-1.0.2"
      sources."has-proto-1.1.0"
      sources."has-symbols-1.1.0"
      sources."hasown-2.0.2"
      sources."he-1.2.0"
      sources."html-encoding-sniffer-3.0.0"
      sources."http-proxy-1.18.1"
      sources."iconv-lite-0.6.3"
      sources."lodash-4.17.21"
      sources."mime-1.6.0"
      sources."minimist-1.2.8"
      sources."mkdirp-0.5.6"
      sources."ms-2.1.3"
      sources."object-inspect-1.13.3"
      sources."opener-1.5.2"
      sources."portfinder-1.0.32"
      sources."qs-6.13.1"
      sources."requires-port-1.0.0"
      sources."safe-buffer-5.1.2"
      sources."safer-buffer-2.1.2"
      sources."secure-compare-3.0.1"
      sources."set-function-length-1.2.2"
      sources."side-channel-1.0.6"
      sources."supports-color-7.2.0"
      sources."union-0.5.0"
      sources."url-join-4.0.1"
      sources."whatwg-encoding-2.0.0"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "A simple zero-configuration command-line http server";
      homepage = "https://github.com/http-party/http-server#readme";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
  sort-package-json = nodeEnv.buildNodePackage {
    name = "sort-package-json";
    packageName = "sort-package-json";
    version = "2.12.0";
    src = fetchurl {
      url = "https://registry.npmjs.org/sort-package-json/-/sort-package-json-2.12.0.tgz";
      sha512 = "/HrPQAeeLaa+vbAH/znjuhwUluuiM/zL5XX9kop8UpDgjtyWKt43hGDk2vd/TBdDpzIyzIHVUgmYofzYrAQjew==";
    };
    dependencies = [
      sources."detect-indent-7.0.1"
      sources."detect-newline-4.0.1"
      sources."fdir-6.4.2"
      sources."get-stdin-9.0.0"
      sources."git-hooks-list-3.1.0"
      sources."is-plain-obj-4.1.0"
      sources."picomatch-4.0.2"
      sources."semver-7.6.3"
      sources."sort-object-keys-1.1.3"
      sources."tinyglobby-0.2.10"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "Sort an Object or package.json based on the well-known package.json keys";
      homepage = "https://github.com/keithamus/sort-package-json#readme";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
  ts-node = nodeEnv.buildNodePackage {
    name = "ts-node";
    packageName = "ts-node";
    version = "10.9.2";
    src = fetchurl {
      url = "https://registry.npmjs.org/ts-node/-/ts-node-10.9.2.tgz";
      sha512 = "f0FFpIdcHgn8zcPSbf1dRevwt047YMnaiJM3u2w2RewrB+fob/zePZcrOyQoLMMO7aBIddLcQIEK5dYjkLnGrQ==";
    };
    dependencies = [
      sources."@cspotcode/source-map-support-0.8.1"
      sources."@jridgewell/resolve-uri-3.1.2"
      sources."@jridgewell/sourcemap-codec-1.5.0"
      sources."@jridgewell/trace-mapping-0.3.9"
      sources."@swc/core-1.10.0"
      sources."@swc/counter-0.1.3"
      sources."@swc/helpers-0.5.15"
      sources."@swc/types-0.1.17"
      sources."@swc/wasm-1.10.0"
      sources."@tsconfig/node10-1.0.11"
      sources."@tsconfig/node12-1.0.11"
      sources."@tsconfig/node14-1.0.3"
      sources."@tsconfig/node16-1.0.4"
      sources."@types/node-22.10.1"
      sources."acorn-8.14.0"
      sources."acorn-walk-8.3.4"
      sources."arg-4.1.3"
      sources."create-require-1.1.1"
      sources."diff-4.0.2"
      sources."make-error-1.3.6"
      sources."tslib-2.8.1"
      sources."typescript-5.7.2"
      sources."undici-types-6.20.0"
      sources."v8-compile-cache-lib-3.0.1"
      sources."yn-3.1.1"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "TypeScript execution environment and REPL for node.js, with source map support";
      homepage = "https://typestrong.org/ts-node";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
}
