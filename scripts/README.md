Scripts

minecraft@.service - start/stop script for minecraft
- requires 'screen' to function

The script uses the value passed into it to identify the server location.  That value is used to set working directory and permissions.  The value is pre-pended with mc- to identify the screen uniquely.  The mc-prefix helps with sorting when doing process work.

The @ allows the systemd job to startup multiple instances as long as directory structure is consistent and adhered to.

Will need to change this if any variable need to deviate in the future, such as one server running papermc and one running spigotmc, etc.

minecraft.sh - backup script
- depends on the structure defined for minecraft@.service. any changes to file structure or that script will drive a need to change this script
- uses the 'screen' calls to execute command lines
- actions are sent to the server users for awareness when the job executes
- scheduled through cron.


