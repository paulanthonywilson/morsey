use Mix.Config

if Mix.env() == :prod do
  # Customize non-Elixir parts of the firmware. See
  # https://hexdocs.pm/nerves/advanced-configuration.html for details.

  config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

  # Use shoehorn to start the main application. See the shoehorn
  # docs for separating out critical OTP applications such as those
  # involved with firmware updates.

  config :shoehorn,
    init: [:nerves_runtime, :nerves_init_gadget],
    app: Mix.Project.config()[:app]

  config :nerves_firmware_ssh,
    authorized_keys: [
      File.read!(Path.join(System.user_home!(), ".ssh/id_rsa.pub"))
    ]

  # Use Ringlogger as the logger backend and remove :console.
  # See https://hexdocs.pm/ring_logger/readme.html for more information on
  # configuring ring_logger.

  config :logger, backends: [RingLogger]

  # import_config "#{Mix.Project.config[:target]}.exs"
end
