defmodule CachingPool.Trial do
    def do_something() do
        :timer.sleep(2_000)

        {:ok, :something}
    end

    def do_something(x) do
        :timer.sleep(2_000)

        {:ok, x}
    end
end