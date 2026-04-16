function Style-Button {
    param(
        [System.Windows.Forms.Button]$Button,
        [System.Drawing.Color]$BackColor,
        [System.Drawing.Color]$ForeColor
    )

    $Button.FlatStyle = 'Flat'
    $Button.FlatAppearance.BorderSize = 1
    $Button.FlatAppearance.BorderColor = $script:ColorBorder
    $Button.BackColor = $BackColor
    $Button.ForeColor = $ForeColor
    $Button.Font = New-Object System.Drawing.Font('Segoe UI', 9)

    $Button.Add_MouseEnter({
        if ($script:IsDarkMode) {
            $this.BackColor = $script:DarkColorButtonHover
            $this.ForeColor = $script:DarkColorText
            $this.FlatAppearance.BorderColor = $script:DarkColorBorder
        } else {
            $this.BackColor = $script:ColorButtonHover
            $this.ForeColor = $script:ColorText
            $this.FlatAppearance.BorderColor = $script:ColorBorder
        }
    })

    $Button.Add_MouseLeave({
        if ($script:IsDarkMode) {
            $this.BackColor = $script:DarkColorButton
            $this.ForeColor = $script:DarkColorText
            $this.FlatAppearance.BorderColor = $script:DarkColorBorder
        } else {
            $this.BackColor = $script:ColorButton
            $this.ForeColor = $script:ColorText
            $this.FlatAppearance.BorderColor = $script:ColorBorder
        }
    })
}

function Style-AccentButton {
    param([System.Windows.Forms.Button]$Button)

    $Button.FlatStyle = 'Flat'
    $Button.FlatAppearance.BorderSize = 0
    $Button.BackColor = $script:ColorAccent
    $Button.ForeColor = [System.Drawing.Color]::White
    $Button.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)

    $Button.Add_MouseEnter({
        if ($script:IsDarkMode) {
            $this.BackColor = $script:DarkColorAccentDark
        } else {
            $this.BackColor = $script:ColorAccentDark
        }
    })

    $Button.Add_MouseLeave({
        if ($script:IsDarkMode) {
            $this.BackColor = $script:DarkColorAccent
        } else {
            $this.BackColor = $script:ColorAccent
        }
    })
}

function Style-TextBox {
    param([System.Windows.Forms.TextBox]$TextBox)

    $TextBox.BackColor = $script:ColorInputBg
    $TextBox.ForeColor = $script:ColorText
    $TextBox.BorderStyle = 'FixedSingle'
    $TextBox.Font = New-Object System.Drawing.Font('Segoe UI', 10)
}

function Style-Label {
    param(
        [System.Windows.Forms.Label]$Label,
        [bool]$Muted = $false,
        [float]$Size = 9,
        [bool]$Bold = $false
    )

    $style = if ($Bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $Label.Font = New-Object System.Drawing.Font('Segoe UI', $Size, $style)
    $Label.ForeColor = if ($Muted) { $script:ColorMutedText } else { $script:ColorText }
    $Label.BackColor = [System.Drawing.Color]::Transparent
}

function New-CardPanel {
    param(
        [int]$X,
        [int]$Y,
        [int]$W,
        [int]$H
    )

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point($X, $Y)
    $panel.Size = New-Object System.Drawing.Size($W, $H)
    $panel.BackColor = $script:ColorPanel
    $panel.BorderStyle = 'FixedSingle'
    return $panel
}