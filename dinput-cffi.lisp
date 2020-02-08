#|
 This file is a part of cl-gamepad
 (c) 2020 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.fraf.gamepad.impl)

(cffi:define-foreign-library dinput
  (T (:default "dinput8")))

(defconstant DINPUT-VERSION #x0800)
(defvar IID-IDIRECTINPUT8
  (make-guid #xBF798031 #x483A #x4DA2 #xAA #x99 #x5D #x64 #xED #x36 #x97 #x00))
(defvar IID-VALVE-STREAMING-GAMEPAD
  (make-guid #x28DE11FF #x0000 #x0000 #x00 #x00 #x50 #x49 #x44 #x56 #x49 #x44))
(defvar IID-X360-WIRED-GAMEPAD
  (make-guid #x045E02A1 #x0000 #x0000 #x00 #x00 #x50 #x49 #x44 #x56 #x49 #x44))
(defvar IID-X360-WIRELESS-GAMEPAD
  (make-guid #x045E028E #x0000 #x0000 #x00 #x00 #x50 #x49 #x44 #x56 #x49 #x44))
(defvar DIPROP-BUFFERSIZE (cffi:make-pointer 1))
(defvar DIPROP-RANGE (cffi:make-pointer 4))
(defvar DIPROP-DEADZONE (cffi:make-pointer 5))

(cffi:defcenum (device-type dword)
  (:all 0)
  (:device 1)
  (:pointer 2)
  (:keyboard 3)
  (:game-controller 4))

(cffi:defbitfield (device-flags dword)
  (:all-devices       #x00000000)
  (:attached-only     #x00000001)
  (:force-feedback    #x00000100)
  (:include-aliases   #x00010000)
  (:include-phantoms  #x00020000)
  (:include-hidden    #x00040000))

(cffi:defbitfield (object-flags dword)
  (:all           #x00000000)
  (:relative-axis #x00000001)
  (:absolute-axis #x00000002)
  (:axis          #x00000003)
  (:push-button   #x00000004)
  (:toggle-button #x00000008)
  (:button        #x0000000C)
  (:pov           #x00000010)
  (:collection    #x00000040)
  (:nodata        #x00000080)
  (:ff-actuator   #x01000000)
  (:ff-trigger    #x02000000))

(cffi:defbitfield (cooperation-flags dword)
  (:exclusive    #x01)
  (:nonexclusive #x02)
  (:foreground   #x04)
  (:background   #x08)
  (:no-win-key   #x10))

(cffi:defcenum (enumerate-flag word)
  (:stop 0)
  (:continue 1))

(cffi:defcenum (property-header-flag dword)
  (:device 0)
  (:by-offset 1)
  (:by-id 2)
  (:by-usage 3))

(cffi:defcstruct (device-instance :conc-name device-instance-)
  (size dword)
  (guid (:struct guid))
  (product (:struct guid))
  (type dword)
  (instance-name tchar :count #.MAX-PATH)
  (product-name tchar :count #.MAX-PATH)
  (ff-driver (:struct guid))
  (usage-page word)
  (usage word))

(cffi:defcstruct (enum-user-data :conc-name enum-user-data-)
  (directinput :pointer)
  (device-array :pointer)
  (device-count :uint8))

(cffi:defcstruct (object-data-format :conc-name object-data-format-)
  (guid :pointer)
  (ofs dword)
  (type dword)
  (flags dword))

(cffi:defcstruct (data-format :conc-name data-format-)
  (size dword)
  (object-size dword)
  (flags dword)
  (data-size dword)
  (object-count dword)
  (object-data-format :pointer))

(cffi:defcstruct (joystate :conc-name joystate-)
  (l-x long)
  (l-y long)
  (l-z long)
  (r-x long)
  (r-y long)
  (r-z long)
  (slider long :count 2)
  (pov dword :count 4)
  (buttons byte :count 32))

(cffi:defcvar (data-format-joystick "c_dfDIJoystick") (:struct data-format))

(cffi:defcstruct (device-capabilities :conc-name device-capabilities-)
  (size dword)
  (flags dword)
  (device-type dword)
  (axes dword)
  (buttons dword)
  (povs dword)
  (sample-period dword)
  (min-time-resolution dword)
  (firmware-revision dword)
  (hardware-revision dword)
  (driver-version dword))

(cffi:defcstruct (property-header :conc-name property-hader-)
  (size dword)
  (header-size dword)
  (object dword)
  (how property-header-flag))

(cffi:defcstruct (property-range :conc-name property-range-)
  (size dword)
  (header-size dword)
  (type dword)
  (how property-header-flag)
  ;; ^ (header (:struct property-header))
  (min long)
  (max long))

(cffi:defcstruct (property-dword :conc-name property-dword-)
  (size dword)
  (header-size dword)
  (type dword)
  (how property-header-flag)
  ;; ^ (header (:struct property-header))
  (data dword))

(cffi:defcstruct (device-object-instance :conc-name device-object-instance-)
  (size dword)
  (guid (:struct guid))
  (ofs dword)
  (type dword)
  (flags dword)
  (name wchar :count #.MAX-PATH)
  (ff-max-force dword)
  (ff-force-resolution dword)
  (collection-number word)
  (designator-index word)
  (usage-page word)
  (usage word)
  (dimension dword)
  (exponent word)
  (reserved word))

(cffi:defcstruct (broadcast-device-interface :conc-name broadcast-device-interface-)
  (size dword)
  (device-type win-device-type)
  (reserved dword)
  (guid (:struct guid))
  (name wchar))

(cffi:defcfun (create-direct-input "DirectInput8Create") hresult
  (instance :pointer)
  (version dword)
  (refiid :pointer)
  (interface :pointer)
  (aggregation :pointer))

(define-comstruct directinput
  (create-device hresult (guid :pointer) (device :pointer) (outer :pointer))
  (enum-devices hresult (type device-type) (callback :pointer) (user :pointer) (flags device-flags))
  (get-device-status hresult (instance :pointer))
  (run-control-panel hresult (owner :pointer) (flags dword))
  (initialize hresult (instance :pointer) (version dword))
  (find-device hresult (guid :pointer) (name :pointer) (instance :pointer))
  (enum-devices-by-semantics hresult (user-name :pointer) (action-format :pointer) (callback :pointer) (user :pointer) (flags dword))
  (configure-devices hresult (callback :pointer) (params :pointer) (flags dword) (user :pointer)))

(define-comstruct device
  (get-capabilities hresult (caps :pointer))
  (enum-objects hresult (callback :pointer) (user :pointer) (flags object-flags))
  (get-property hresult (property :pointer) (header :pointer))
  (set-property hresult (property :pointer) (header :pointer))
  (acquire hresult)
  (unacquire hresult)
  (get-device-state hresult (data dword) (data* :pointer))
  (get-device-data hresult (object-data dword) (object-data* :pointer) (inout :pointer) (flags dword))
  (set-data-format hresult (format :pointer))
  (set-event-notification hresult (event :pointer))
  (set-cooperative-level hresult (hwnd :pointer) (flags cooperation-flags))
  (get-object-info hresult (instance :pointer) (object dword) (how dword))
  (get-device-info hresult (instance :pointer))
  (run-control-panel hresult (owner :pointer) (flags dword))
  (initialize hresult (instance :pointer) (version dword) (guid :pointer))
  (create-effect hresult (guid :pointer) (effect :pointer) (input-effect :pointer) (user :pointer))
  (enum-effects hresult (callback :pointer) (user :pointer) (type dword))
  (get-effect-info hresult (info :pointer) (guid :pointer))
  (get-force-feedback-state hresult (out :pointer))
  (send-force-feedback-command hresult (flags dword))
  (enum-created-effect-objects hresult (callback :pointer) (user :pointer) (flags dword))
  (escape hresult (escape :pointer))
  (poll hresult)
  (send-device-data hresult (object-data dword) (object-data* :pointer) (inout :pointer) (flags dword))
  (enum-effects-in-file hresult (file-name :pointer) (callback :pointer) (user :pointer) (flags dword))
  (write-effect-to-file hresult (file-name :pointer) (entries dword) (effects :pointer) (flags dword))
  (bild-action-map hresult (format :pointer) (user-name :pointer) (flags dword))
  (set-action-map hresult (format :pointer) (user-name :pointer) (flags dword))
  (get-image-info hresult (image-info :pointer)))
