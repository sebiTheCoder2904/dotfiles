# Load existing autoconfig settings
config.load_autoconfig()

# Prevent dark mode from inverting images
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.policy.images = "never"

# Optional: Fine-tune other elements
# c.colors.webpage.darkmode.policy.page = "smart"
