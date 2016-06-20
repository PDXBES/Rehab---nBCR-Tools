using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PipXP
{
    class SQLiteBasicStrings
    {
        public static string attachDatabase(string databaseLocation, string aliasName)
        {
            return "ATTACH DATABASE '" + databaseLocation + "' As '" + aliasName + "'; ";
        }

        public static string enableSpatial()
        {
            return "SELECT load_extension('C:\\Program Files (x86)\\ArcGIS\\Desktop10.2\\DatabaseSupport\\SQLite\\Windows32\\stgeometry_sqlite.dll', 'SDE_SQL_funcs_init');";
        }

    }
}
