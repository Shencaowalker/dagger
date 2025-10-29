package databases

import (
	"dagger/backend/runtime"
	"fmt"
	"log"

	"gorm.io/driver/postgres"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var (
	DB *gorm.DB
)

func init() {
	// debug, _ := runtime.Cfg.Bool("global", "debug")
	// loglevel := logger.Default.LogMode(logger.Error)
	// if debug {
	// 	loglevel = logger.Default.LogMode(logger.Info)
	// }

	var err error

	// addr, _ := runtime.Cfg.GetValue("db", "address")
	// dsn := "host=10.5.100.113 user=postgres password=postgres dbname=log port=5432 sslmode=disable TimeZone=Asia/Shanghai"
	dbtype, _ := runtime.Cfg.GetValue("db", "dbtype")
	dsn, _ := runtime.Cfg.GetValue("db", "address")
	fmt.Print("dsn is:  ", dsn)

	// dsn = "host=10.5.100.113 user=postgres password=postgres dbname=log port=5432 sslmode=disable TimeZone=Asia/Shanghai"
	if dbtype == "mysql" {
		debug, _ := runtime.Cfg.Bool("global", "debug")
		loglevel := logger.Default.LogMode(logger.Error)
		if debug {
			loglevel = logger.Default.LogMode(logger.Info)
		}
		DB, err = gorm.Open(mysql.Open(dsn), &gorm.Config{
			DisableForeignKeyConstraintWhenMigrating: true,
			Logger:                                   loglevel,
		})
	} else if dbtype == "postgres" {
		DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	}

	if err != nil {
		log.Panicf("db connect error %v", err)
	}
	if DB.Error != nil {
		log.Panicf("database error %v", DB.Error)
	}
}
