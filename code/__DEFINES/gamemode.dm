// Security levels.
#define SEC_LEVEL_GREEN  0
#define SEC_LEVEL_BLUE   1
#define SEC_LEVEL_YELLOW 2
#define SEC_LEVEL_VIOLET 3
#define SEC_LEVEL_ORANGE 4
#define SEC_LEVEL_RED    5
#define SEC_LEVEL_DELTA  6

#define BE_PAI        (1<<14)

var/list/be_special_flags = list(
	"pAI"              = BE_PAI
)

#define DEFAULT_TELECRYSTAL_AMOUNT 120
