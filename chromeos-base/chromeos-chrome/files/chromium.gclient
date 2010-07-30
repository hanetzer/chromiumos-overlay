solutions = [
  { "name"        : "src",
    "url"         : "http://src.chromium.org/svn/trunk/src",
    "custom_deps" : {
     	        "src/third_party/WebKit/LayoutTests": None,
    },
    "safesync_url": "http://chromium-status.appspot.com/lkgr"
  },
  { "name" : "cros_deps",
    "url" : "http://src.chromium.org/svn/trunk/cros_deps",
    "safesync_url": "http://chromium-status.appspot.com/lkgr"
  }
]
