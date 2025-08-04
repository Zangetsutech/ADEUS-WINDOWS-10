# =================================================================================================
# Script:         Secure-Bypass-And-Install-Win11-V9-UNRESTRICTED-FIDO-MCT-POPCNT-FIX.ps1
# Description:    Versao com verificacao de POPCNT corrigida usando Coreinfo.
#                 ADICIONADO: Opcoes de download via Fido e Media Creation Tool.
#                 CORRIGIDO: Conflito de parametros "RunAs" e "NoNewWindow" no acesso ao registro.
# Disclaimer:     Use por sua conta e risco.
# =================================================================================================

# --- Requisito de Administrador ---
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

# --- Definicoes da GUI (Windows Forms) ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Variaveis Globais e de Registro ---
$script:isoPath = ""
$BackupFolder = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop", "Win11_Bypass_Backup")
$script:backupFileAppCompat = ""
$script:backupFileMoSetup = ""
$script:mountedImage = $null

# Caminhos das chaves a serem manipuladas
$AppCompatKeyPath = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags"
$MoSetupKeyPath = "HKLM\SYSTEM\Setup"

# --- Criacao do Formulario Principal ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "ADEUS WINDOWS 10!"
$form.Size = New-Object System.Drawing.Size(500, 600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false
$form.MinimizeBox = $false

# Etapa 1
$step1Label = New-Object System.Windows.Forms.Label
$step1Label.Location = New-Object System.Drawing.Point(20, 20)
$step1Label.Size = New-Object System.Drawing.Size(460, 20)
$step1Label.Text = "Etapa 1: Inicie o backup e aplique o bypass ou restaure."
$step1Label.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($step1Label)

$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Location = New-Object System.Drawing.Point(20, 50)
$applyButton.Size = New-Object System.Drawing.Size(220, 40)
$applyButton.Text = "Aplicar Bypass e Fazer Backup"
$applyButton.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$applyButton.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#C8E6C9")
$form.Controls.Add($applyButton)

$restoreButton = New-Object System.Windows.Forms.Button
$restoreButton.Location = New-Object System.Drawing.Point(250, 50)
$restoreButton.Size = New-Object System.Drawing.Size(220, 40)
$restoreButton.Text = "Restaurar"
$restoreButton.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$restoreButton.BackColor = [System.Drawing.ColorTranslator]::fromHtml("#FFCDD2")
$restoreButton.Enabled = $false
$form.Controls.Add($restoreButton)


# --- ETAPA 1.5: DOWNLOAD DA ISO ---
$step1_5Label = New-Object System.Windows.Forms.Label
$step1_5Label.Location = New-Object System.Drawing.Point(20, 110)
$step1_5Label.Size = New-Object System.Drawing.Size(460, 20)
$step1_5Label.Text = "Etapa 1.5 (Opcional): Obtenha uma ISO do Windows."
$step1_5Label.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($step1_5Label)

$downloadIsoButton = New-Object System.Windows.Forms.Button
$downloadIsoButton.Location = New-Object System.Drawing.Point(20, 140)
$downloadIsoButton.Size = New-Object System.Drawing.Size(220, 40)
$downloadIsoButton.Text = "Baixar ISO (via Fido)"
$downloadIsoButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$downloadIsoButton.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#D1C4E9")
$form.Controls.Add($downloadIsoButton)

$mctButton = New-Object System.Windows.Forms.Button
$mctButton.Location = New-Object System.Drawing.Point(250, 140)
$mctButton.Size = New-Object System.Drawing.Size(220, 40)
$mctButton.Text = "Criar ISO (MCT Oficial)"
$mctButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$mctButton.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#B3E5FC")
$form.Controls.Add($mctButton)


# Etapa 2
$step2Label = New-Object System.Windows.Forms.Label
$step2Label.Location = New-Object System.Drawing.Point(20, 200)
$step2Label.Size = New-Object System.Drawing.Size(420, 20)
$step2Label.Text = "Etapa 2: Selecione o ISO do Windows 11 e inicie."
$step2Label.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($step2Label)

$selectIsoButton = New-Object System.Windows.Forms.Button
$selectIsoButton.Location = New-Object System.Drawing.Point(50, 230)
$selectIsoButton.Size = New-Object System.Drawing.Size(180, 40)
$selectIsoButton.Text = "Selecionar Arquivo ISO..."
$selectIsoButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.Controls.Add($selectIsoButton)

$isoPathBox = New-Object System.Windows.Forms.TextBox
$isoPathBox.Location = New-Object System.Drawing.Point(50, 280)
$isoPathBox.Size = New-Object System.Drawing.Size(380, 20)
$isoPathBox.ReadOnly = $true
$isoPathBox.Text = "Nenhum arquivo ISO selecionado."
$form.Controls.Add($isoPathBox)

$installButton = New-Object System.Windows.Forms.Button
$installButton.Location = New-Object System.Drawing.Point(50, 320)
$installButton.Size = New-Object System.Drawing.Size(380, 50)
$installButton.Text = "Iniciar"
$installButton.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$installButton.BackColor = [System.Drawing.ColorTranslator]::fromHtml("#BBDEFB")
$installButton.Enabled = $false
$form.Controls.Add($installButton)

$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Location = New-Object System.Drawing.Point(20, 390)
$statusBox.Size = New-Object System.Drawing.Size(450, 160)
$statusBox.ReadOnly = $true
$statusBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$statusBox.Text = "Aguardando acao..."
$form.Controls.Add($statusBox)


# --- Funcoes ---
function Log-Status ($message, $color = "Black") {
    if ($statusBox.Text -eq "Aguardando acao...") { $statusBox.Clear() }
    $statusBox.SelectionStart = $statusBox.TextLength
    $statusBox.SelectionLength = 0
    $statusBox.SelectionColor = $color
    $statusBox.AppendText("$(Get-Date -Format 'HH:mm:ss') - $message`r`n")
    $statusBox.ScrollToCaret()
    $statusBox.Refresh()
}

# ================================================================
# FUNCAO DE VERIFICACAO DE POPCNT CORRIGIDA
# ================================================================
function Test-PopcntSupport {
    # Caminho para a ferramenta Coreinfo na pasta temporaria do usuario
    $coreinfoPath = Join-Path $env:TEMP "coreinfo.exe"
    # URL oficial de download do Coreinfo da Microsoft
    $coreinfoUrl = "https://live.sysinternals.com/coreinfo.exe"

    try {
        # 1. Baixar o Coreinfo se ele ainda nao existir localmente
        if (-not (Test-Path $coreinfoPath)) {
            Log-Status "Baixando Coreinfo da Microsoft para verificar a CPU..." "Blue"
            # O -UseBasicParsing e mais compativel com versoes antigas do PowerShell
            Invoke-WebRequest -Uri $coreinfoUrl -OutFile $coreinfoPath -UseBasicParsing
        }

        # 2. Executar o Coreinfo e capturar a saida de texto
        Log-Status "Analisando o suporte a instrucao POPCNT..."
        # O argumento "-accepteula" e crucial para evitar que o script pare aguardando a aceitacao da licenca
        $cpuInfo = & $coreinfoPath -accepteula
        
        # 3. Procurar pela linha do POPCNT e verificar se ela contem o asterisco (*) que indica suporte
        $popcntSupportLine = $cpuInfo | Where-Object { $_ -match "^\s*POPCNT\s" }
        
        if ($popcntSupportLine -and $popcntSupportLine -match '\*') {
            # O asterisco foi encontrado, a CPU suporta a instrucao.
            return $true
        } else {
            # A linha nao foi encontrada ou nao tem o asterisco, nao ha suporte.
            return $false
        }

    } catch {
        # 4. Tratar qualquer erro que possa ocorrer (falha no download, execucao bloqueada, etc.)
        Log-Status "ERRO: Falha ao executar a verificacao de CPU com Coreinfo. $($_.Exception.Message)" "Red"
        # Em caso de falha, e mais seguro assumir que nao ha suporte para proteger o usuario.
        return $false
    }
}
# ================================================================

function CheckForExistingBackup {
    if (Test-Path $BackupFolder) {
        $latestAppCompat = Get-ChildItem -Path $BackupFolder -Filter "AppCompatFlags_*.reg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $latestMoSetup = Get-ChildItem -Path $BackupFolder -Filter "MoSetup_*.reg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latestAppCompat -and $latestMoSetup) {
            $script:backupFileAppCompat = $latestAppCompat.FullName
            $script:backupFileMoSetup = $latestMoSetup.FullName
            $restoreButton.Enabled = $true
            Log-Status "Backup anterior encontrado. O botao de restauracao esta ativo." "Blue"
        }
    }
}

# --- Logica dos Botoes ---
$applyButton.Add_Click({
    try {
        Log-Status "Iniciando processo de backup..."; if (-NOT(Test-Path $BackupFolder)) { New-Item -Path $BackupFolder -ItemType Directory | Out-Null; Log-Status "Pasta de backup criada em: $BackupFolder" }
        $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'; $script:backupFileAppCompat = Join-Path $BackupFolder "AppCompatFlags_$timestamp.reg"; $script:backupFileMoSetup = Join-Path $BackupFolder "MoSetup_$timestamp.reg"
        
        Log-Status "Exportando chave AppCompatFlags..."; Start-Process reg.exe -ArgumentList "export `"$AppCompatKeyPath`" `"$($script:backupFileAppCompat)`" /y" -Wait -NoNewWindow
        Log-Status "Exportando chave MoSetup..."; Start-Process reg.exe -ArgumentList "export `"$MoSetupKeyPath`" `"$($script:backupFileMoSetup)`" /y" -Wait -NoNewWindow
        
        if ((Test-Path $script:backupFileAppCompat) -and (Test-Path $script:backupFileMoSetup)) { Log-Status "Backup concluido com SUCESSO!" "DarkGreen"; $restoreButton.Enabled = $true } else { Throw "A criacao do arquivo de backup falhou!" }
        Log-Status "Iniciando aplicacao do bypass..."; Log-Status "Limpando marcadores de compatibilidade antigos..."
        
        Start-Process reg.exe -ArgumentList 'delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\CompatMarkers" /f' -Verb RunAs -Wait
        Start-Process reg.exe -ArgumentList 'delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Shared" /f' -Verb RunAs -Wait
        Start-Process reg.exe -ArgumentList 'delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators" /f' -Verb RunAs -Wait
        Log-Status "Configurando bypass de Requisitos de Hardware (HwReqChk)..."
        Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" /f /v HwReqChkVars /t REG_MULTI_SZ /s , /d "SQ_SecureBootCapable=TRUE,SQ_SecureBootEnabled=TRUE,SQ_TpmVersion=2,SQ_RamMB=8192,"' -Verb RunAs -Wait
        Log-Status "Configurando bypass de TPM/CPU (MoSetup)..."
        Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\Setup\MoSetup" /f /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1' -Verb RunAs -Wait
        Log-Status "Bypass abrangente aplicado com SUCESSO!" "Green"
    } catch { Log-Status "ERRO CRITICO: $($_.Exception.Message)" "Red" }
})

$restoreButton.Add_Click({
    if ((-not(Test-Path $script:backupFileAppCompat)) -or (-not(Test-Path $script:backupFileMoSetup))) {
        Log-Status "ERRO: Arquivos de backup nao encontrados ou nao definidos." "Red"; return
    }
    try {
        Log-Status "Iniciando restauracao a partir do backup..." "Blue"
        
        Start-Process reg.exe -ArgumentList "import `"$($script:backupFileAppCompat)`"" -Verb RunAs -Wait
        Start-Process reg.exe -ArgumentList "import `"$($script:backupFileMoSetup)`"" -Verb RunAs -Wait
        
        Log-Status "Restauracao do registro concluida com SUCESSO." "Blue"
        $restoreButton.Enabled = $false
    } catch { Log-Status "ERRO ao restaurar do backup: $($_.Exception.Message)" "Red" }
})

$downloadIsoButton.Add_Click({
    $fidoUrl = "https://raw.githubusercontent.com/pbatard/Fido/master/Fido.ps1"
    $fidoPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop", "Fido.ps1")

    try {
        Log-Status "Baixando o script Fido.ps1 para a sua Area de Trabalho..." "Blue"
        Invoke-WebRequest -Uri $fidoUrl -OutFile $fidoPath
        Log-Status "Download do Fido.ps1 concluido com SUCESSO!" "DarkGreen"
        
        Log-Status "Iniciando o script Fido.ps1..." "Blue"
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$fidoPath`""
        Log-Status "Fido foi iniciado em uma nova janela. Siga as instrucoes la." "Blue"

    } catch {
        Log-Status "ERRO CRITICO ao baixar o Fido.ps1: $($_.Exception.Message)" "Red"
        [System.Windows.Forms.MessageBox]::Show("Nao foi possivel baixar o Fido.ps1. Verifique sua conexao com a internet ou o link.", "Erro de Download", "OK", "Error") | Out-Null
    }
})

$mctButton.Add_Click({
    $mctUrl = "https://go.microsoft.com/fwlink/?linkid=2156295"
    $mctPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop", "MediaCreationTool.exe")

    try {
        Log-Status "Baixando Media Creation Tool para sua Área de Trabalho..." "Blue"
        Invoke-WebRequest -Uri $mctUrl -OutFile $mctPath
        Log-Status "Download do Media Creation Tool concluido com SUCESSO!" "DarkGreen"
        
        $mctArgs = "/Eula Accept /Action CreateMedia /MediaLangCode pt-BR /MediaArch x64 /MediaEdition Professional"
        Start-Process -FilePath $mctPath -ArgumentList $mctArgs
        
    } catch {
        Log-Status "ERRO CRITICO ao baixar ou executar o Media Creation Tool: $($_.Exception.Message)" "Red"
        [System.Windows.Forms.MessageBox]::Show("Nao foi possivel baixar ou iniciar a ferramenta. Verifique sua conexao com a internet ou permissoes.", "Erro de Automacao", "OK", "Error") | Out-Null
    }
})

$selectIsoButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog; $openFileDialog.Title = "Selecione o arquivo ISO do Windows 11"; $openFileDialog.Filter = "Arquivos ISO (*.iso)|*.iso"
    $openFileDialog.InitialDirectory = [System.Environment]::GetFolderPath('Desktop')
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:isoPath = $openFileDialog.FileName
        $isoPathBox.Text = $script:isoPath
        $installButton.Enabled = $true
        Log-Status "Arquivo ISO selecionado: $($script:isoPath)"
    }
})

$installButton.Add_Click({
    Log-Status "Iniciando processo de instalacao... Certifique-se de que o bypass foi aplicado." "Blue"
    try {
        Log-Status "Tentando montar o ISO em: $($script:isoPath)"
        $script:mountedImage = Mount-DiskImage -ImagePath $script:isoPath -PassThru -ErrorAction Stop
        if (-not $script:mountedImage) { Throw "Mount-DiskImage falhou em retornar um objeto." }
        $volume = $script:mountedImage | Get-Volume
        if (-not $volume) { Throw "Nao foi possivel obter informacoes de volume." }
        $driveLetter = $volume.DriveLetter
        if (-not $driveLetter) { Throw "A letra da unidade nao foi encontrada." }
        Log-Status "ISO montado com SUCESSO na unidade $($driveLetter):" "Green"
        
        $setupPath = Join-Path -Path "$($driveLetter):" -ChildPath "setup.exe"
        if (-not(Test-Path $setupPath)) { Throw "'setup.exe' nao foi encontrado na raiz do ISO montado." }
        Log-Status "Iniciando o instalador do Windows 11..."
        Start-Process -FilePath $setupPath
        Log-Status "O instalador foi iniciado. Esta janela pode ser fechada."
    } catch {
        Log-Status "ERRO DURANTE A MONTAGEM OU INSTALACAO: $($_.Exception.Message)" "Red"
        if ($script:mountedImage) {
            Log-Status "Tentando desmontar a imagem ISO..."
            Dismount-DiskImage -ImagePath $script:isoPath -ErrorAction SilentlyContinue
            $script:mountedImage = $null
        }
    }
})

# --- Inicializacao e Limpeza ---
Log-Status "Verificando requisitos de CPU (POPCNT)..."
if (-not (Test-PopcntSupport)) {
    $errorMessage = "FALHA CRITICA: Seu processador nao possui a instrucao POPCNT, um requisito OBRIGATORIO para o Windows 11 24H2 ou superior. A instalacao nao sera possivel com esta CPU. As funcoes de bypass e instalacao foram desativadas."
    Log-Status $errorMessage "Red"
    [System.Windows.Forms.MessageBox]::Show($errorMessage, "Requisito de CPU Nao Atendido", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Stop) | Out-Null
    
    $applyButton.Enabled = $false
    $applyButton.BackColor = [System.Drawing.Color]::Gray
    $downloadIsoButton.Enabled = $false
    $downloadIsoButton.BackColor = [System.Drawing.Color]::LightGray
    $mctButton.Enabled = $false
    $mctButton.BackColor = [System.Drawing.Color]::LightGray
    $selectIsoButton.Enabled = $false
    $selectIsoButton.BackColor = [System.Drawing.Color]::LightGray
    $installButton.Enabled = $false
    $installButton.BackColor = [System.Drawing.Color]::Gray
} else {
    Log-Status "SUCESSO: Seu processador SUPORTA a instrucao POPCNT." "DarkGreen"
}
Log-Status "------------------------------------------------------------" "Black"

CheckForExistingBackup

# Evento de Fechamento do Formulario para Limpeza
$form.Add_FormClosing({
    try {
        if ($script:mountedImage) {
            Write-Host "Limpando: Desmontando imagem ISO em $($script:isoPath)..." -ForegroundColor Yellow
            Dismount-DiskImage -ImagePath $script:isoPath -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Warning "Falha ao desmontar a imagem durante o fechamento."
    }
})

# Exibir o formulario
[void]$form.ShowDialog()
