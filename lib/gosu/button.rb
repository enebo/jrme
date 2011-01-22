module Gosu
  module Button
    Kb0 = KeyInput::KEY_0
    Kb1 = KeyInput::KEY_1
    Kb2 = KeyInput::KEY_2
    Kb3 = KeyInput::KEY_3
    Kb4 = KeyInput::KEY_4
    Kb5 = KeyInput::KEY_5
    Kb6 = KeyInput::KEY_6
    Kb7 = KeyInput::KEY_7
    Kb8 = KeyInput::KEY_8
    Kb9 = KeyInput::KEY_9
    KbA = KeyInput::KEY_A
    KbB = KeyInput::KEY_B
    KbC = KeyInput::KEY_C
    KbD = KeyInput::KEY_D
    KbE = KeyInput::KEY_E
    KbF = KeyInput::KEY_F
    KbG = KeyInput::KEY_G
    KbH = KeyInput::KEY_H
    KbI = KeyInput::KEY_I
    KbJ = KeyInput::KEY_J
    KbK = KeyInput::KEY_K
    KbL = KeyInput::KEY_L
    KbM = KeyInput::KEY_M
    KbN = KeyInput::KEY_N
    KbO = KeyInput::KEY_O
    KbP = KeyInput::KEY_P
    KbQ = KeyInput::KEY_Q
    KbR = KeyInput::KEY_R
    KbS = KeyInput::KEY_S
    KbT = KeyInput::KEY_T
    KbU = KeyInput::KEY_U
    KbV = KeyInput::KEY_V
    KbW = KeyInput::KEY_W
    KbX = KeyInput::KEY_X
    KbY = KeyInput::KEY_Y
    KbZ = KeyInput::KEY_Z
    KbBackspace = KeyInput::KEY_BACK
    KbDelete = KeyInput::KEY_DELETE
    KbDown = KeyInput::KEY_DOWN
    KbEnd = KeyInput::KEY_END
    KbEnter = KeyInput::KEY_RETURN
    KbEscape = KeyInput::KEY_ESCAPE
    KbF1 = KeyInput::KEY_F1
    KbF10 = KeyInput::KEY_F10
    KbF11 = KeyInput::KEY_F11
    KbF12 = KeyInput::KEY_F12
    KbF2 = KeyInput::KEY_F2
    KbF3 = KeyInput::KEY_F3
    KbF4 = KeyInput::KEY_F4
    KbF5 = KeyInput::KEY_F5
    KbF6 = KeyInput::KEY_F6
    KbF7 = KeyInput::KEY_F7
    KbF8 = KeyInput::KEY_F8
    KbF9 = KeyInput::KEY_F9
    KbHome = KeyInput::KEY_HOME
    KbInsert = KeyInput::KEY_INSERT
    KbLeft = KeyInput::KEY_LEFT
    KbLeftAlt = KeyInput::KEY_LMENU
    KbLeftControl = KeyInput::KEY_LCONTROL
    KbLeftShift = KeyInput::KEY_LSHIFT
    KbNumpad0 = KeyInput::KEY_NUMPAD0
    KbNumpad1 = KeyInput::KEY_NUMPAD1
    KbNumpad2 = KeyInput::KEY_NUMPAD2
    KbNumpad3 = KeyInput::KEY_NUMPAD3
    KbNumpad4 = KeyInput::KEY_NUMPAD4
    KbNumpad5 = KeyInput::KEY_NUMPAD5
    KbNumpad6 = KeyInput::KEY_NUMPAD6
    KbNumpad7 = KeyInput::KEY_NUMPAD7
    KbNumpad8 = KeyInput::KEY_NUMPAD8
    KbNumpad9 = KeyInput::KEY_NUMPAD9
    KbNumpadAdd = KeyInput::KEY_ADD
    KbNumpadDivide = KeyInput::KEY_DIVIDE
    KbNumpadMultiply = KeyInput::KEY_MULTIPLY
    KbNumpadSubtract = KeyInput::KEY_SUBTRACT
    KbPageDown = KeyInput::KEY_PGDN
    KbPageUp = KeyInput::KEY_PGUP
    KbPause = KeyInput::KEY_PAUSE
    KbReturn = KeyInput::KEY_RETURN
    KbRight = KeyInput::KEY_RIGHT
    KbRightAlt = KeyInput::KEY_RMENU
    KbRightControl = KeyInput::KEY_RCONTROL
    KbRightShift = KeyInput::KEY_RSHIFT
    KbSpace = KeyInput::KEY_SPACE
    KbTab = KeyInput::KEY_TAB
    KbUp = KeyInput::KEY_UP
    # TODO: Fix
    MsLeft = KeyInput::KEY_A
    MsMiddle = KeyInput::KEY_A
    MsRight = KeyInput::KEY_A
    MsWheelDown = KeyInput::KEY_A
    MsWheelUp = KeyInput::KEY_A
    GpButton0 = KeyInput::KEY_A
    GpButton1 = KeyInput::KEY_A
    GpButton10 = KeyInput::KEY_A
    GpButton11 = KeyInput::KEY_A
    GpButton12 = KeyInput::KEY_A
    GpButton13 = KeyInput::KEY_A
    GpButton14 = KeyInput::KEY_A
    GpButton15 = KeyInput::KEY_A
    GpButton2 = KeyInput::KEY_A
    GpButton3 = KeyInput::KEY_A
    GpButton4 = KeyInput::KEY_A
    GpButton5 = KeyInput::KEY_A
    GpButton6 = KeyInput::KEY_A
    GpButton7 = KeyInput::KEY_A
    GpButton8 = KeyInput::KEY_A
    GpButton9 = KeyInput::KEY_A
    GpDown = KeyInput::KEY_A
    GpLeft = KeyInput::KEY_A
    GpRight = KeyInput::KEY_A
    GpUp = KeyInput::KEY_A

    MAPPINGS = Gosu::Button.constants.inject({}) do |map, constant|
      map[Gosu::Button.const_get(constant)] = constant
      map
    end
  end
end
