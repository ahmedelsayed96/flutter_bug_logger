## 支持手机上查看源码
- 因为如果要在手机上查看日志的源码，需要依赖 VM Service，
本地运行需要添加额外参数，以确保能够连接到 VM Service，运行的时候添加以下参数
```dart
--disable-dds
```

- 因为依赖了 VM Service 可能会导致其他代码冲突，又考虑到 在手机上查看源码的场景并不多，所以单独拿出来了，
- 在手机上 日志输出的地方 直接点击 就可以查看源码了

<img src="https://github.com/niezhiyang/flutter_logger/blob/dev/art/code.gif" width="30%">