PKG = com/allsparkcube
THRIFT_DIR = ../../thrift/gen-java/$(PKG)
THRIFT_IMPL_FILE = CubeInterface.java
SRC_DIR = src/main/java/$(PKG)
DEMO_DIR = demo
DEMO_CLASSNAME = CubeDemo
LOADTEST_CLASSNAME = LoadTest
JAR_FILE = `find target -name "cube_client*standalone.jar"`

jar: clean
	@cp $(THRIFT_DIR)/$(THRIFT_IMPL_FILE) $(SRC_DIR)
	@mvn package -q

run: jar
	@javac -cp $(JAR_FILE) $(DEMO_DIR)/$(DEMO_CLASSNAME).java
	@java -cp $(JAR_FILE):$(DEMO_DIR) $(DEMO_CLASSNAME)

loadtest: jar
	@javac -cp $(JAR_FILE) $(DEMO_DIR)/$(LOADTEST_CLASSNAME).java
	@java -cp $(JAR_FILE):$(DEMO_DIR) $(LOADTEST_CLASSNAME)

clean:
	@-rm -f $(SRC_DIR)/$(THRIFT_IMPL_FILE)
	@mvn clean -q

.PHONY: jar run loadtest clean

