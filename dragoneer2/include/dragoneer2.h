#define DgnMethod( methodName ) (*methodName)
#define DgnSelf void* self
#define DgnInterface( interfaceName ) struct __dummy____##interfaceName##_Vft___
#define DgnInherits( parentInterfaceName )