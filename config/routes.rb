Rails.application.routes.draw do
  # ヘルスチェック
  get "health", to: "monitoring#health"

  # ログイン系
  root to: redirect("/login")
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"

  # 基本機能系
  resources :chats, only: %i[index show]
  resources :slips
  resources :sidebar, only: [:index]
  resources :messages, only: %i[show update]

  # 設定系
  namespace :settings do
    resource :lists, only: [:show]
    resources :users, except: [:show]
    resources :groups, except: [:show]
  end

  # API系
  namespace :api do
    resources :geo, only: [:create]
  end

  # 開発ツール
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
