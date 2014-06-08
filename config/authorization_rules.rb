authorization do
  role :guest do
    has_permission_on :homepage, to: [:index]
    has_permission_on :sessions, to: [:new, :create, :destroy]
    has_permission_on :users, to: [:new, :create]
    has_permission_on :products, to: [:index, :show]
    has_permission_on :donations, to: [:new, :create]
    has_permission_on :cart_items, to: [:index, :create, :destroy, :empty, :checkout]
  end

  role :admin do
    includes :guest
    has_permission_on :products, to: [:new, :create, :edit, :update, :destroy]
  end

  role :god do
    has_omnipotence
  end
end
