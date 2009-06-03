java_import java.awt.Font
java_import java.awt.GridBagConstraints
java_import java.awt.GridBagLayout
java_import java.awt.Insets

java_import javax.swing.ButtonGroup
java_import javax.swing.JCheckBox
java_import javax.swing.JComboBox
java_import javax.swing.JFrame
java_import javax.swing.JLabel
java_import javax.swing.JRadioButton

class ShadowTweaker < JFrame
  def initialize(pass)
    super()
    @lmethodGroup = ButtonGroup.new()
    @@spass = pass
    getContentPane().setLayout(GridBagLayout.new())
    setTitle("ShadowTweaker")
    setBounds(100, 100, 388, 443)
    setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)

    blendForLightLabel = JLabel.new()
    blendForLightLabel.setText("Blend for Light Passes (S/D):")
    gridBagConstraints = GridBagConstraints.new()
    gridBagConstraints.gridwidth = 2
    gridBagConstraints.insets = Insets.new(10, 10, 0, 10)
    gridBagConstraints.anchor = GridBagConstraints::NORTHWEST
    gridBagConstraints.gridy = 0
    gridBagConstraints.gridx = 0
    getContentPane().add(blendForLightLabel, gridBagConstraints)

    srcBlendOptions = BlendState::SourceFunction.values()
    dstBlendOptions = BlendState::DestinationFunction.values()

    @additiveRadioButton = JRadioButton.new()
    @additiveRadioButton.addActionListener { |e| setLMode() }
    modulativeRadioButton = JRadioButton.new()
    modulativeRadioButton.addActionListener { |e| setLMode() }


    @lPassSrcBlend = lPassSrcBlend = JComboBox.new(srcBlendOptions)
    lPassSrcBlend.addActionListener do |e|
      if (@additiveRadioButton && @additiveRadioButton.isSelected() && ShadowedRenderPass.blended)
        ShadowedRenderPass.blended.setSourceFunction(lPassSrcBlend.getSelectedItem())
      elsif (modulativeRadioButton && modulativeRadioButton.isSelected() && ShadowedRenderPass.modblended)
        ShadowedRenderPass.modblended.setSourceFunction(lPassSrcBlend.getSelectedItem())
      end
    end

    @lPassSrcBlend.setFont(Font.new("Arial", Font::PLAIN, 8))
    gridBagConstraints_1 = GridBagConstraints.new()
    gridBagConstraints_1.anchor = GridBagConstraints::NORTHWEST
    gridBagConstraints_1.insets = Insets.new(0, 10, 0, 10)
    gridBagConstraints_1.weightx = 1
    gridBagConstraints_1.fill = GridBagConstraints::HORIZONTAL
    gridBagConstraints_1.gridwidth = 2
    gridBagConstraints_1.gridy = 1
    gridBagConstraints_1.gridx = 0
    getContentPane().add(@lPassSrcBlend, gridBagConstraints_1)

    @lPassDstBlend = lPassDstBlend = JComboBox.new(dstBlendOptions)
    @lPassDstBlend.addActionListener do |e|
      if (@additiveRadioButton && @additiveRadioButton.isSelected() && ShadowedRenderPass.blended)
        ShadowedRenderPass.blended.setDestinationFunction(lPassDstBlend.getSelectedItem())
      elsif (modulativeRadioButton && modulativeRadioButton.isSelected() && ShadowedRenderPass.modblended)
        ShadowedRenderPass.modblended.setDestinationFunction(lPassDstBlend.getSelectedItem())
      end
    end

    @lPassDstBlend.setFont(Font.new("Arial", Font::PLAIN, 8))
    gridBagConstraints_3 = GridBagConstraints.new()
    gridBagConstraints_3.insets = Insets.new(0, 10, 0, 10)
    gridBagConstraints_3.fill = GridBagConstraints::HORIZONTAL
    gridBagConstraints_3.gridwidth = 2
    gridBagConstraints_3.gridy = 3
    gridBagConstraints_3.gridx = 0
    getContentPane().add(lPassDstBlend, gridBagConstraints_3)

    blendForTextureLabel = JLabel.new()
    blendForTextureLabel.setText("Blend for Texture Pass (S/D):")
    gridBagConstraints_8 = GridBagConstraints.new()
    gridBagConstraints_8.gridwidth = 2
    gridBagConstraints_8.insets = Insets.new(10, 10, 0, 10)
    gridBagConstraints_8.anchor = GridBagConstraints::NORTHWEST
    gridBagConstraints_8.gridy = 4
    gridBagConstraints_8.gridx = 0
    getContentPane().add(blendForTextureLabel, gridBagConstraints_8)

    @tPassSrcBlend = tPassSrcBlend = JComboBox.new(srcBlendOptions)
    @tPassSrcBlend.addActionListener do |e|
      if (ShadowedRenderPass.blendTex)
        ShadowedRenderPass.blendTex.setSourceFunction(tPassSrcBlend.getSelectedItem())
      end
    end
    tPassSrcBlend.setFont(Font.new("Arial", Font::PLAIN, 8))
    gridBagConstraints_9 = GridBagConstraints.new()
    gridBagConstraints_9.insets = Insets.new(0, 10, 0, 10)
    gridBagConstraints_9.fill = GridBagConstraints::HORIZONTAL
    gridBagConstraints_9.gridwidth = 2
    gridBagConstraints_9.gridy = 5
    gridBagConstraints_9.gridx = 0
    getContentPane().add(tPassSrcBlend, gridBagConstraints_9)

    @tPassDstBlend = tPassDstBlend = JComboBox.new(dstBlendOptions)
    @tPassDstBlend.addActionListener do |e|
      if (ShadowedRenderPass.blendTex)
        ShadowedRenderPass.blendTex.setDestinationFunction(tPassDstBlend.getSelectedItem())
      end
    end
    tPassDstBlend.setFont(Font.new("Arial", Font::PLAIN, 8))
    gridBagConstraints_10 = GridBagConstraints.new()
    gridBagConstraints_10.insets = Insets.new(0, 10, 0, 10)
    gridBagConstraints_10.fill = GridBagConstraints::HORIZONTAL
    gridBagConstraints_10.gridwidth = 2
    gridBagConstraints_10.gridy = 6
    gridBagConstraints_10.gridx = 0
    getContentPane().add(tPassDstBlend, gridBagConstraints_10)

    @enableShadowsCheckBox = JCheckBox.new()
    @enableShadowsCheckBox.addActionListener do |e|
      @@spass.setRenderShadows(@enableShadowsCheckBox.isSelected())
    end
    @enableShadowsCheckBox.setSelected(true)
    @enableShadowsCheckBox.setText("Enable Shadows")
    gridBagConstraints_4 = GridBagConstraints.new()
    gridBagConstraints_4.anchor = GridBagConstraints::SOUTH
    gridBagConstraints_4.insets = Insets.new(10, 10, 0, 10)
    gridBagConstraints_4.gridy = 7
    gridBagConstraints_4.gridx = 0
    getContentPane().add(@enableShadowsCheckBox, gridBagConstraints_4)

    @enableTextureCheckBox = JCheckBox.new()
    @enableTextureCheckBox.addActionListener do |e|
      ShadowedRenderPass.rTexture = @enableTextureCheckBox.isSelected()
    end
    @enableTextureCheckBox.setSelected(true)
    @enableTextureCheckBox.setText("Enable Texture")
    gridBagConstraints_2 = GridBagConstraints.new()
    gridBagConstraints_2.anchor = GridBagConstraints::SOUTH
    gridBagConstraints_2.gridy = 7
    gridBagConstraints_2.gridx = 1
    getContentPane().add(@enableTextureCheckBox, gridBagConstraints_2)

    methodLabel = JLabel.new()
    methodLabel.setText("Lighting Method:")
    gridBagConstraints_7 = GridBagConstraints.new()
    gridBagConstraints_7.insets = Insets.new(4, 10, 0, 10)
    gridBagConstraints_7.anchor = GridBagConstraints::NORTHWEST
    gridBagConstraints_7.gridy = 8
    gridBagConstraints_7.gridx = 0
    getContentPane().add(methodLabel, gridBagConstraints_7)

    @lmethodGroup.add(@additiveRadioButton)
    @additiveRadioButton.setSelected(true)
    @additiveRadioButton.setText("ADDITIVE")
    gridBagConstraints_5 = GridBagConstraints.new()
    gridBagConstraints_5.weightx = 0.5
    gridBagConstraints_5.gridy = 9
    gridBagConstraints_5.gridx = 0
    getContentPane().add(@additiveRadioButton, gridBagConstraints_5)

    @lmethodGroup.add(modulativeRadioButton)
    modulativeRadioButton.setText("MODULATIVE")
    gridBagConstraints_6 = GridBagConstraints.new()
    gridBagConstraints_6.weightx = 0.5
    gridBagConstraints_6.gridy = 9
    gridBagConstraints_6.gridx = 1
    getContentPane().add(modulativeRadioButton, gridBagConstraints_6)
    setLMode()
  end

  def setLMode()
    if (@additiveRadioButton.isSelected())
      @@spass.setLightingMethod(ShadowedRenderPass::LightingMethod::Additive)
      @lPassDstBlend.setSelectedItem(BlendState::DestinationFunction::One)
      @lPassSrcBlend.setSelectedItem(BlendState::SourceFunction::DestinationColor)
      @tPassDstBlend.setSelectedItem(BlendState::DestinationFunction::Zero)
      @tPassSrcBlend.setSelectedItem(BlendState::SourceFunction::DestinationColor)
      @enableTextureCheckBox.setText("Enable Texture Pass")
    else
      @@spass.setLightingMethod(ShadowedRenderPass::LightingMethod::Modulative)
      @lPassDstBlend.setSelectedItem(BlendState::DestinationFunction::OneMinusSourceAlpha)
      @lPassSrcBlend.setSelectedItem(BlendState::SourceFunction::DestinationColor)
      @enableTextureCheckBox.setText("Enable Dark Pass")
    end
  end
end
