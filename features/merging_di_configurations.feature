@virtual @merging
Feature: Merging DI configurations

  Background:
    Given I have the feature:
      """
      Feature: FooBar

        Scenario: Fake Foo with Real Bar
          Given The foo service is "Acme\FooBar\Test\Service\FakeFoo"
          And The bar service is "Acme\FooBar\Service\Bar"
          Then The merge is correct
      """
    And I have no Magento module called "Acme_FooBar"
    And I have a Magento module called "Acme_FooBar"
    And I have an interface "Acme\FooBar\Service\FooInterface" defined in this module:
      """
      <?php

      namespace Acme\FooBar\Service;

      interface FooInterface
      {
          public function foo(): void;
      }
      """
    And I have an interface "Acme\FooBar\Service\BarInterface" defined in this module:
      """
      <?php

      namespace Acme\FooBar\Service;

      interface BarInterface
      {
          public function bar(): void;
      }
      """
    And I have a class "Acme\FooBar\Service\Foo" defined in this module:
      """
      <?php

      namespace Acme\FooBar\Service;

      class Foo implements FooInterface
      {
          public function foo(): void
          {
          }
      }
      """
    And I have a class "Acme\FooBar\Service\Bar" defined in this module:
      """
      <?php

      namespace Acme\FooBar\Service;

      class Bar implements BarInterface
      {
          public function bar(): void
          {
          }
      }
      """
    And I have a class "Acme\FooBar\Service\FooBar" defined in this module:
      """
      <?php

      namespace Acme\FooBar\Service;

      class FooBar
      {
          public $foo;
          public $bar;

          public function __construct(FooInterface $foo, BarInterface $bar)
          {
              $this->foo = $foo;
              $this->bar = $bar;
          }
      }
      """
    And I have a class "Acme\FooBar\Test\Service\FakeFoo" defined in this module:
      """
      <?php

      namespace Acme\FooBar\Test\Service;

      use Acme\FooBar\Service\FooInterface;

      class FakeFoo implements FooInterface
      {
          public function foo(): void
          {
          }
      }
      """
    And I have the context:
      """
      <?php

      use Acme\FooBar\Service\FooBar;
      use Behat\Behat\Context\Context;
      use Acme\Awesome\Service\DeliveryCostCalculator;
      use Acme\Awesome\Test\FakeConfigProvider;
      use PHPUnit\Framework\Assert;

      class FeatureContext implements Context
      {
          /** @Given The foo service is :expected */
          public function checkFoo($expected, FooBar $foobar): void
          {
              Assert::assertInstanceof($expected, $foobar->foo);
          }

          /** @Given The bar service is :expected */
          public function checkBar($expected, FooBar $foobar): void
          {
              Assert::assertInstanceof($expected, $foobar->bar);
          }

          /** @Then The merge is correct */
          public function yay(): void {}
      }
      """
    And I flush the cache
    And I run the Magento command "module:enable" with arguments "Acme_FooBar"

  Scenario: Merging global and test area correctly
    Given I have a global Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <type name="Acme\FooBar\Service\FooBar">
              <arguments>
                  <argument name="foo" xsi:type="object">Acme\FooBar\Service\Foo</argument>
                  <argument name="bar" xsi:type="object">Acme\FooBar\Service\Bar</argument>
              </arguments>
          </type>
      </config>
      """
    And I have a test Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <type name="Acme\FooBar\Service\FooBar">
              <arguments>
                  <argument name="foo" xsi:type="object">Acme\FooBar\Test\Service\FakeFoo</argument>
              </arguments>
          </type>
      </config>
      """
    And I have the configuration:
      """
      default:
        suites:
          application:
            autowire: true
            contexts:
              - FeatureContext
            services: '@seec.magento2_extension.service_container'
            magento:
              area: test

        extensions:
          SEEC\Behat\Magento2Extension: ~
      """
    When I run Behat
    Then I should see the tests passing

  Scenario: Merging frontend and test area correctly
    Given I have a frontend Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <type name="Acme\FooBar\Service\FooBar">
              <arguments>
                  <argument name="foo" xsi:type="object">Acme\FooBar\Service\Foo</argument>
                  <argument name="bar" xsi:type="object">Acme\FooBar\Service\Bar</argument>
              </arguments>
          </type>
      </config>
      """
    And I have a test Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <type name="Acme\FooBar\Service\FooBar">
              <arguments>
                  <argument name="foo" xsi:type="object">Acme\FooBar\Test\Service\FakeFoo</argument>
              </arguments>
          </type>
      </config>
      """
    And I have the configuration:
      """
      default:
        suites:
          application:
            autowire: true
            contexts:
              - FeatureContext
            services: '@seec.magento2_extension.service_container'
            magento:
              area: [frontend, test]

        extensions:
          SEEC\Behat\Magento2Extension: ~
      """
    When I run Behat
    Then I should see the tests passing

  Scenario: Merging adminhtml and test area correctly
    Given I have an adminhtml Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <type name="Acme\FooBar\Service\FooBar">
              <arguments>
                  <argument name="foo" xsi:type="object">Acme\FooBar\Service\Foo</argument>
                  <argument name="bar" xsi:type="object">Acme\FooBar\Service\Bar</argument>
              </arguments>
          </type>
      </config>
      """
    And I have a test Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <type name="Acme\FooBar\Service\FooBar">
              <arguments>
                  <argument name="foo" xsi:type="object">Acme\FooBar\Test\Service\FakeFoo</argument>
              </arguments>
          </type>
      </config>
      """
    And I have the configuration:
      """
      default:
        suites:
          application:
            autowire: true
            contexts:
              - FeatureContext
            services: '@seec.magento2_extension.service_container'
            magento:
              area: [adminhtml, test]

        extensions:
          SEEC\Behat\Magento2Extension: ~
      """
    When I run Behat
    Then I should see the tests passing

  Scenario: Preserving global configuration when merging multiple areas
    Given I have a global Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <preference for="Acme\FooBar\Service\BarInterface" type="Acme\FooBar\Service\Bar" />
      </config>
      """
    And I have an adminhtml Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <type name="Acme\FooBar\Service\FooBar">
              <arguments>
                  <argument name="foo" xsi:type="object">Acme\FooBar\Service\Foo</argument>
              </arguments>
          </type>
      </config>
      """
    And I have a test Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <type name="Acme\FooBar\Service\FooBar">
              <arguments>
                  <argument name="foo" xsi:type="object">Acme\FooBar\Test\Service\FakeFoo</argument>
              </arguments>
          </type>
      </config>
      """
    And I have the configuration:
      """
      default:
        suites:
          application:
            autowire: true
            contexts:
              - FeatureContext
            services: '@seec.magento2_extension.service_container'
            magento:
              area: [adminhtml, test]

        extensions:
          SEEC\Behat\Magento2Extension: ~
      """
    When I run Behat
    Then I should see the tests passing

  Scenario: Overriding global fallback configuration when merging multiple areas
    Given I have a global Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <preference for="Acme\FooBar\Service\FooInterface" type="Acme\FooBar\Service\Foo" />
      </config>
      """
    And I have an adminhtml Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <type name="Acme\FooBar\Service\FooBar">
              <arguments>
                  <argument name="bar" xsi:type="object">Acme\FooBar\Service\Bar</argument>
              </arguments>
          </type>
      </config>
      """
    And I have a test Magento DI configuration in this module:
      """
      <?xml version="1.0"?>
      <config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
          <preference for="Acme\FooBar\Service\FooInterface" type="Acme\FooBar\Test\Service\FakeFoo" />
      </config>
      """
    And I have the configuration:
      """
      default:
        suites:
          application:
            autowire: true
            contexts:
              - FeatureContext
            services: '@seec.magento2_extension.service_container'
            magento:
              area: [adminhtml, test]

        extensions:
          SEEC\Behat\Magento2Extension: ~
      """
    When I run Behat
    Then I should see the tests passing
