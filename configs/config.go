package configs

import "github.com/spf13/viper"

var conf *APIConfig

type APIConfig struct {
	Port string
}

func init() {
	viper.SetDefault("api.port", "8080")
}

func Load() error {
	viper.SetConfigName("api")
	viper.SetConfigType("config")
	viper.AddConfigPath(".")
	err := viper.ReadInConfig()
	if err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			return err
		}
	}

	conf = new(APIConfig)
	conf.Port = viper.GetString("api.port")

	return nil
}

func GetServerPort() string {
	return conf.Port
}
