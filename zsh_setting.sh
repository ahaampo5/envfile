#!/bin/bash

# 패키지 설치 함수
install_packages() {
    local packages=("$@")
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo "macOS 감지됨. Homebrew로 패키지 설치 중..."
        if command -v brew &> /dev/null; then
            for package in "${packages[@]}"; do
                echo "Installing $package..."
                brew install "$package"
            done
        else
            echo "Homebrew가 설치되지 않았습니다. 먼저 Homebrew를 설치해주세요."
            echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
            return 1
        fi
    elif [[ -f /etc/os-release ]]; then
        # Linux 배포판 확인
        . /etc/os-release
        case $ID in
            ubuntu|debian)
                echo "Ubuntu/Debian 감지됨. apt로 패키지 설치 중..."
                sudo apt update
                for package in "${packages[@]}"; do
                    echo "Installing $package..."
                    sudo apt install -y "$package"
                done
                ;;
            fedora|centos|rhel)
                echo "Fedora/CentOS/RHEL 감지됨."
                if command -v dnf &> /dev/null; then
                    for package in "${packages[@]}"; do
                        echo "Installing $package..."
                        sudo dnf install -y "$package"
                    done
                else
                    for package in "${packages[@]}"; do
                        echo "Installing $package..."
                        sudo yum install -y "$package"
                    done
                fi
                ;;
            arch|manjaro)
                echo "Arch Linux 감지됨. pacman으로 패키지 설치 중..."
                for package in "${packages[@]}"; do
                    echo "Installing $package..."
                    sudo pacman -S --noconfirm "$package"
                done
                ;;
            *)
                echo "지원되지 않는 Linux 배포판: $ID"
                echo "수동으로 패키지들을 설치해주세요: ${packages[*]}"
                return 1
                ;;
        esac
    else
        echo "OS를 감지할 수 없습니다."
        return 1
    fi
}

# 필수 패키지들 확인 및 설치
check_and_install_packages() {
    local missing_packages=()
    local packages_to_check=("zsh" "git" "curl" "wget" "fasd" "fzf" "tree" "neofetch" "tmux" "neovim")
    
    echo "필수 패키지들을 확인 중..."
    
    for package in "${packages_to_check[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            echo "$package가 설치되지 않았습니다."
            missing_packages+=("$package")
        else
            echo "$package가 이미 설치되어 있습니다: $(which $package)"
            if [[ "$package" == "zsh" ]]; then
                echo "zsh 버전: $(zsh --version)"
            fi
        fi
    done
    
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        echo "누락된 패키지들을 설치합니다: ${missing_packages[*]}"
        install_packages "${missing_packages[@]}"
    else
        echo "모든 필수 패키지가 이미 설치되어 있습니다."
    fi
}

# 패키지 확인 및 설치 실행
check_and_install_packages

# 기본 셸을 zsh로 변경할지 묻기
if command -v zsh &> /dev/null; then
    echo ""
    echo "zsh를 기본 셸로 설정하시겠습니까? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        chsh -s $(which zsh)
        echo "기본 셸이 zsh로 변경되었습니다. 재로그인하면 적용됩니다."
    fi
else
    echo "zsh 설치에 실패했습니다. 수동으로 설치해주세요."
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "Oh My Zsh 설치가 완료되었습니다."
echo "zsh 설정이 완료되었습니다. 터미널을 다시 시작하세요."

# Convert ZSH_THEME="robbyrussell" to ZSH_THEME="agnoster"
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc
echo "ZSH_THEME가 agnoster로 변경되었습니다."

# Add Plugin
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
echo "zsh-autosuggestions 플러그인이 설치되었습니다."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "zsh-syntax-highlighting 플러그인이 설치되었습니다."
git clone https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/extract ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/extract
echo "extract 플러그인이 설치되었습니다."
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
echo "zsh-history-substring-search 플러그인이 설치되었습니다."
git clone https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/colored-man-pages ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/colored-man-pages
echo "colored-man-pages 플러그인이 설치되었습니다."
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
echo "fzf-tab 플러그인이 설치되었습니다."
# Enable Plugin
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab extract colored-man-pages zsh-history-substring-search fasd)/' ~/.zshrc

# Config Directory
mkdir -p ~/.config/nvim

source ~/.zshrc
