# system-lock-ai

System-level, self-repairing blocker for AI services on Linux. (created by AI)

---

### **EXTREME WARNING**

> This script makes permanent, self-repairing changes to your system to block AI services. **There is no uninstallation script and no official uninstallation guide provided.** Proceed ONLY if you understand the consequences and are capable of manually reversing low-level system changes without guidance. You are solely responsible for the outcome.

---

### Mechanism of Action

This tool is designed to be resilient against casual attempts at removal. It achieves this through three mechanisms:

1.  **`/etc/hosts` Modification:** A comprehensive list of AI-related domains is added to `/etc/hosts`, redirecting all traffic to `0.0.0.0` (IPv4) and `::1` (IPv6).
2.  **Immutable File Attribute:** The `/etc/hosts` file is flagged as immutable (`chattr +i`), preventing modification or deletion even by the root user.
3.  **Self-Repairing `systemd` Daemon:** A persistent `systemd` service runs in the background under a generic system name. Every 10 seconds, this daemon checks:
    *   If the immutable flag on `/etc/hosts` has been removed. If so, it immediately reapplies it.
    *   If its own `systemd` service has been disabled or masked. If so, it immediately re-enables itself.

This creates a feedback loop that actively resists tampering.

### System Requirements

*   A `systemd`-based Linux distribution (e.g., Arch Linux, Debian, Ubuntu, Fedora).
*   Root privileges (`sudo`) for installation.

### Installation

```bash
# Clone the repository
git clone https://github.com/differthecopier/Block_AI.git
cd Block_AI

# Grant execution permissions
chmod +x install.sh

# Run the installer as root. This is the final step. There is no turning back.
sudo ./install.sh
