defmodule CachingPool.API do
    use CachingPool.Easy, module: :hackney, ttl: 100
end