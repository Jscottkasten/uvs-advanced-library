#####
# Crappy makefile.

# Set these.
BUILD_ID        = 17
ANDROID_HOME    = $(HOME)/Android/android-sdk-linux
MIRAH_PATH      = $(HOME)/Android/jruby-1.7.27/bin
JVM             = 1.6
JAVA_OPTIONS    = -Xmx64m
                 # -Xss64m

# Don't touch these.
ANDROID_JAR     = $(ANDROID_HOME)/platforms/android-$(BUILD_ID)/android.jar
ANDROID_V4_JAR  = $(ANDROID_HOME)/extras/android/support/v4/android-support-v4.jar
SOURCES         = ./Src/Mirah/Android/.
DESTINATION     = ./Bin/Classes
DISTRIBUTABLES  = ./Distributables/Android
CLASSPATH       = $(DESTINTION):$(ANDROID_JAR):$(ANDROID_V4_JAR)
TARGET_LIB      = UVS-Android-AdvancedLibrary.jar


all : dist

.PHONY : debug clean dist

clean :
	-[ -d $(DESTINATION) ] || mkdir --parents $(DESTINATION)
	-rm -rf log Bin/Classes/*

debug : clean
	-date >log
	-(PATH="$(MIRAH_PATH):$(PATH)" ; export _JAVA_OPTIONS="$(JAVA_OPTIONS)" ; mirahc --no-color --jvm $(JVM) --classpath "$(CLASSPATH)" --dest "$(DESTINATION)" "$(SOURCES)" ) >>log 2>&1
	-date >>log
	less log

dist : debug
	-[ -d $(DISTRIBUTABLES) ] || mkdir --parents $(DISTRIBUTABLES)
	-[ -f $(DISTRIBUTABLES)/$(TARGET_LIB) ] && rm -rf $(DISTRIBUTABLES)/$(TARGET_LIB)
	-jar -cvf $(DISTRIBUTABLES)/$(TARGET_LIB) -C $(DESTINATION) com
