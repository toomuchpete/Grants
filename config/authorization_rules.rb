authorization do
  role :guest do
    has_permission_on :homepage, to: [:index]
    has_permission_on :sessions, to: [:new, :create, :destroy]
    has_permission_on :users, to: [:new, :create]
  end
end
